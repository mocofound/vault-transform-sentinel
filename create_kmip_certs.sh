export VAULT_ADDR=http://20.163.249.35:8200
export VAULT_TOKEN=""
sudo curl --output vault_1.13.1+ent_linux_amd64.zip "https://releases.hashicorp.com/vault/1.13.1+ent/vault_1.13.1+ent_linux_amd64.zip"
sudo unzip -o vault_1.13.1+ent_linux_amd64.zip 
#sudo su - oracle

# ###
# ### Generate Credential  
sudo cp vault /usr/local/bin
#sudo rm ca_vault.pem cert.pem kmip.json
vault write -f -namespace=on-prem -format=json kmip/adppoc/dev/scope/oracletde/role/admin/credential/generate | tee kmip.json

yum install jq -y

jq --raw-output --exit-status '.data.ca_chain[]' kmip.json > ca_vault.pem
jq --raw-output --exit-status '.data.certificate' kmip.json > cert_vault.pem
