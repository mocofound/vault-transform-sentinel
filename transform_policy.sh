cat <<EOF> transform_policy.hcl
# To request data encoding using any of the roles
# Specify the role name in the path to narrow down the scope
path "transform/encode/*" {
   capabilities = [ "update" ]
}

# To request data decoding using any of the roles
# Specify the role name in the path to narrow down the scope
path "transform/decode/*" {
   capabilities = [ "update" ]
}
EOF

vault policy write transform_policy transform_policy.hcl

vault token create -policy=default -policy=transform_policy
