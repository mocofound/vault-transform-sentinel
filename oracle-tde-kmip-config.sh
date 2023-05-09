
###Install opensc package containing pkcs11-tool for testing
sudo yum install opensc -y

####Search for existing pkcs11 libraries
p11-kit list-modules
whereis p11-kit-trust.so
#/usr/lib64/p11-kit-trust.so

###Configure Vault Logging
sudo touch vault.log
sudo chmod 777 vault.log
export VAULT_LOG_FILE=~/vault.log
export VAULT_LOG_LEVEL=WARN

###Download HashiCorp Vault PKCS11-provider
sudo curl --output vault-pkcs11-provider_0.2.0_linux-el8_amd64.zip "https://releases.hashicorp.com/vault-pkcs11-provider/0.2.0/vault-pkcs11-provider_0.2.0_linux-el8_amd64.zip"
sudo unzip vault-pkcs11-provider_0.2.0_linux-el8_amd64.zip


###Configure HashiCorp Vault PKCS11-provider
cat <<EOF > "vault-pkcs11.hcl"
slot {
  server = "20.163.249.35:5696"
  tls_cert_path = "cert.pem"
  ca_path = "ca.pem"
  scope = "oracletde"
}
EOF

###Test KMIP Commands
sudo pkcs11-tool --module ./libvault-pkcs11.so -L
sudo pkcs11-tool --module ./libvault-pkcs11.so --keygen -a abc123 --key-type AES:32 

###Enable TDE on Oracle Database
#https://developer.hashicorp.com/vault/docs/enterprise/pkcs11-provider/oracle-tde#enable-tde


####
#Archive
#
# #    nano pk.pem
# #    chmod 600 pk.pem
# #    ssh -i pk.pem vadmin@20.163.204.247

# ###
# ### Set Up Vault CLI
# export VAULT_ADDR=http://20.163.249.35:8200
# export VAULT_TOKEN=hvs.pvrsQwxuc3F6aeBTokcr...
# sudo curl --output vault_1.13.1+ent_linux_amd64.zip "https://releases.hashicorp.com/vault/1.13.1+ent/vault_1.13.1+ent_linux_amd64.zip"
# sudo unzip -o vault_1.13.1+ent_linux_amd64.zip 
# sudo cp vault /usr/local/bin
# sudo rm ca.pem cert.pem kmip.json
# #sudo su - oracle

# ###
# ### Generate Credential  
# vault write -f -namespace=on-prem -format=json kmip/adppoc/dev/scope/oracletde/role/admin/credential/generate | tee kmip.json

# yum install jq -y

# jq --raw-output --exit-status '.data.ca_chain[]' kmip.json > ca.pem
# jq --raw-output --exit-status '.data.certificate' kmip.json > cert.pem



#old commands for referene
#pkcs11-tool --module ./libvault-pkcs11.so --keygen -a abc123 --key-type AES:32 --extractable --allow-sw 2>/dev/null
#sudo pkcs11-tool --module ./libvault-pkcs11.so --keygen -a abc123 --key-type AES:32 --extractable --allowed-mechanisms "RSA-PKCS,SHA1-RSA-PKCS,RSA-PKCS-PSS,SHA384-RSA-PKCS"


###Troubleshooting opensc package install
#sudo apt install opensc -y
#sudo yum-config-manager --setopt=sslverify=false --save
# sudo yum update ca-certificates
# sudo yum --disablerepo='*' remove 'rhui-azure-rhel8' -y
# sudo wget "https://rhelimage.blob.core.windows.net/repositories/rhui-microsoft-azure-rhel8.config"
# sudo yum --config=rhui-microsoft-azure-rhel8.config install rhui-azure-rhel8 -y
# sudo yum update ca-certificates -y
# sudo yum clean all -y

#PKCS Config for RHEL VM
# sudo cat << EOF > "vault-pkcs11.hcl"
# slot {
#   server = "20.163.249.35:5696"
#   tls_cert_path = "/home/vadmin/cert.pem"
#   ca_path = "/home/vadmin/ca.pem"
#   scope = "oracletde"
#   #emulate_hardware = true
# }
# EOF