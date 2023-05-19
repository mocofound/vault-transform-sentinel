 ### Set Variables
 $Vault_Address       = 'http://20.163.249.1:8200'
 $Vault_Namespace     = 'on-prem'
 $RoleID              = 'ca8d4b76-af11-efc8-76d1-9f1434696'
 $SecretID            = '9f3eec93-542a-f685-e204-0334e8b'
 
 #Set env variable for vault address
 $VAULT_ROOT          = $Vault_Address + '/v1'
 $VAULT_LOGIN_APPROLE = $VAULT_ROOT+'/auth/approle/login'
 $VAULT_TRANSIT_PATH       = $VAULT_ROOT+'/transit/keys'
 $ENV:VAULT_ADDR = $Vault_Address
 $ENV:VAULT_NAMESPACE = $Vault_Namespace
 
 #Header
 $approleheader = @{
      "X-Vault-Namespace" =  "$($ENV:VAULT_NAMESPACE)"
 }
 
 #Payload
 $payload = @{
   "role_id"   = $RoleID
   "secret_id" = $SecretID
 }
 
 #Get client token from approle login
 $Client_Token = Invoke-RestMethod -Method Post -Uri $VAULT_LOGIN_APPROLE -body $payload -header $approleheader 
 
 #Set vault token environment variable
 $ENV:VAULT_TOKEN = $Client_Token.auth.client_token
 write-host $env:VAULT_TOKEN
 
 #Header
 $header = @{
      "X-Vault-Token" =  "$($ENV:VAULT_TOKEN)"
      "X-Vault-Namespace" =  "$($ENV:VAULT_NAMESPACE)"
 }
 
 $Transit = Invoke-RestMethod -Method Get -Uri $VAULT_TRANSIT_PATH -Headers $header
 
 $Transit
 
 
 ##Get the password from KV
 #$KV_Password = Invoke-RestMethod -Method Get -Uri $VAULT_KV_PATH -Headers $header
 
 #$KV_Password
 
 #curl --header "X-Vault-Token: ..."  --request LIST  http://127.0.0.1:8200/v1/transit/keys 
 