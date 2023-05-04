$Env:VAULT_ADDR="https://<changeme>:8200"
$Env:VAULT_TOKEN="<changeme>"
$Env:VAULT_NAMESPACE="root"

$Env:VAULT_ADDR
$Env:VAULT_TOKEN
$Env:VAULT_NAMESPACE

$header = @{
    "X-Vault-Token" =  "$($Env:VAULT_TOKEN)"
    "X-Vault-Namespace" = "$($Env:VAULT_NAMESPACE)"
}

$postParams = @{value='1111-2222-3333-4444';transformation='ccn-fpe'}
Invoke-RestMethod -Uri "$Env:VAULT_ADDR/v1/transform/encode/payments" -Headers $header -Method POST -Body $postParams

$decodeParams = @{value='7882-2304-1586-9036'}
Invoke-RestMethod -Uri "$Env:VAULT_ADDR/v1/transform/decode/payments" -Headers $header -Method POST -Body $decodeParams
 
