export VAULT_ADDR=http://<changeme>:8200
export VAULT_TOKEN=<changeme>

curl --header "X-Vault-Token: ${VAULT_TOKEN}" \
       --request POST \
       --data '{"value": "1111-2222-3333-4444","transformation": "ccn-fpe"}' \
       http://127.0.0.1:8200/v1/transform/encode/payments
       
curl --header "X-Vault-Token: $VAULT_TOKEN" \
      --request POST \
      --data '{"value": "3330-9570-2888-3352"}'
      VAULT_ADDR/v1/transform/decode/payments 
      
      

#if curl doesn't work you can do this below cli commands
#download and install Vault to use below CLI commands on client
#brew install vault (osx)
#can also be downloaded from here: https://releases.hashicorp.com/vault/1.13.1/

#vault write transform/encode/payments value=1111-2222-3333-4444
#vault write transform/decode/payments/last-four value=9300-3376-4943-8903
