#!/bin/bash
set -ax

#Description
#This example shows how to configure the Transform Secret Engine in HashiCorp Vault Enterprise
#Additionally, this example shows an example Sentinel policy guaranteeing dates 
#submitted to Vault's encode API endpoint are within the previous 300 years

#Prerequisites
#Requires Vault Enterprise License
#Requires Vault Enterprise Binary.  Example:  https://releases.hashicorp.com/vault/1.4.2+ent/
#Requires running Vault instance  Example Dev Instance:  vault server -dev -dev-root-token-id changeme -log-level=trace

#Configure client to talk to Vault
export VAULT_ADDR=http://localhost:8200
export VAULT_TOKEN=changeme

#License Vault Enterprise Advanced Data Protection (ADP)
###Comment out this block if using Vault 1.8+ as license is now required to be bootstraped prior to starting Vault
export VAULT_ENTERPRISE_LICENSE="01MV4UU43BK5HGYYTOJZ..."
vault write sys/license text=$VAULT_ENTERPRISE_LICENSE

#Configure Transform Secret engine to detect MM-DD-YYYY pattern
vault secrets enable transform
vault write transform/role/dates transformations=date-transform
vault write transform/template/month_day_year \
	type=regex pattern='(\d{2})-(\d{2})-(\d{4})' alphabet=numerics
vault write transform/transformation/date-transform \
	type=fpe template=month_day_year \
	tweak_source=internal allowed_roles=dates
vault write transform/alphabet/numerics alphabet="0123456789"

#Create Sentinel Policy
tee lessthan300years.sentinel <<EOF
# HashiCorp Sentinel Policy for Vault
# Details: Date passed to API is not within allowed range

import "time"
import "strings"
import "types"

years_allowed = 300
current_year = time.now.year
encode_input_string = request.data
batch_inputs = request.data.batch_input else [request.data]

  # Print some information about the request
  # Note: these messages will only be printed when the policy is violated
  print("Namespace path:", namespace.path)
  print("Request path:", request.path)
  print("Request data:", request.data)
  print("Current year:", string(current_year))
  print("Years allowed:", string(years_allowed))

# Function that validates dates
validate_dates = func() {

	count = 0
	return_value = true
	num_inputs = length(batch_inputs)
	for batch_inputs as b {
        	encode_input_year = batch_inputs[count]["value"][6:10]
		date_validate = (int(current_year) - int(encode_input_year)) <= years_allowed
		if (date_validate  == false) {
			return_value = false
		}
		count = count + 1
	}

  return return_value
}

# Sentinel Policy Main Rule
dates_validated = validate_dates()
main = rule {
  dates_validated
}
EOF

POLICY=$(base64 lessthan300years.sentinel); vault write sys/policies/egp/dates_300 \
     policy="${POLICY}" \
     paths="*" \
     enforcement_level="hard-mandatory"

#Configure client with non-root token for testing
#Note: Sentinel policies do NOT evaluate against Vault root tokens.  Non-root tokens are required.
cat <<EOF> non_root_token_policy.hcl
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF

vault policy write non_root_token_policy non_root_token_policy.hcl

echo "Creating Token: "; vault token create -policy=default -policy=non_root_token_policy

echo "Enter created token value: "; read NON_ROOT_TOKEN

export VAULT_TOKEN=${NON_ROOT_TOKEN}

tee input-single.json <<EOF
{
	"value": "01-01-1800",
	"transformation": "date-transform"
}
EOF

#Example single request using cURL with Vault API
curl --header "X-Vault-Token: ${VAULT_TOKEN}" \
       --request POST \
       --data '{"value": "01-01-1800","transformation": "date-transform"}' \
       http://127.0.0.1:8200/v1/transform/encode/dates | jq

#JSON for batch input
tee input-multiple.json <<EOF
{
  "batch_input": [
    {
      "value": "01-01-2000",
      "transformation": "date-transform"
    },
    {
      "value": "01-01-1800",
      "transformation": "date-transform"
    },
    {
      "value": "01-01-1900",
      "transformation": "date-transform"
    }
  ]
}
EOF

#Example batch request using cURL with Vault API
curl --header "X-Vault-Token: ${VAULT_TOKEN}" \
       --request POST \
       --data @input-multiple.json \
       http://127.0.0.1:8200/v1/transform/encode/dates | jq

#Example requests using Vault CLI
vault write transform/encode/dates value=01-01-2000
vault write transform/encode/dates value=01-01-1700
vault write transform/encode/dates value=01-01-1900
