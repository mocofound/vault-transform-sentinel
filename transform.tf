resource "vault_mount" "mount_transform" {
  #namespace = ""
  path = "transform"
  type = "transform"
}

resource "vault_transform_role" "test" {
  #namespace = ""
  path = vault_mount.mount_transform.path
  name = "payments"
  transformations = ["ccn-fpe", "ssn", "email", "name", "bankacctnum"]
}


resource "vault_transform_transformation" "example" {
  #namespace = ""
  path          = vault_mount.mount_transform.path
  name          = "ccn-fpe"
  type          = "fpe"
  template      = "builtin/creditcardnumber"
  tweak_source  = "internal"
  allowed_roles = ["payments"]
}

resource "vault_transform_alphabet" "numerics" {
  #namespace = ""
  path      = vault_mount.mount_transform.path
  name      = "numerics"
  alphabet  = "0123456789"
}

resource "vault_transform_template" "ssn" {
  #namespace = ""
  path           = vault_transform_alphabet.numerics.path
  name           = "ssn"
  type           = "regex"
  pattern        = "(\\d{3})[- ](\\d{2})[- ](\\d{4})"
  alphabet       = "numerics"
  encode_format  = "$1-$2-$3"
  decode_formats = {
    "last-four-digits" = "$3"
  }
}

resource "vault_transform_transformation" "ssn" {
  #namespace = ""
  path          = vault_mount.mount_transform.path
  name          = "ssn"
  type          = "fpe"
  template      = "ssn"
  tweak_source  = "internal"
  allowed_roles = ["payments"]
}



resource "vault_transform_template" "email" {
  #namespace = ""
  path           = vault_transform_alphabet.numerics.path
  name           = "email"
  type           = "regex"
  pattern        = "(.*)@.*"
  alphabet       = "email"
  #encode_format  = "$1"
  #decode_formats = {
  #  "email" = "$1"
  #}
}

resource "vault_transform_transformation" "email" {
  #namespace = ""
  path          = vault_mount.mount_transform.path
  name          = "email"
  type          = "fpe"
  template      = "email"
  tweak_source  = "internal"
  allowed_roles = ["payments"]
}

resource "vault_transform_template" "bankacctnum" {
  #namespace = ""
  path           = vault_transform_alphabet.numerics.path
  name           = "bankacctnum"
  type           = "regex"
  pattern        = "(^[0-9]{9,18}$)"
  alphabet       = "numerics"
  encode_format  = "$1"
  decode_formats = {
    "acct" = "$1"
  }
}

resource "vault_transform_transformation" "bankacctnum" {
  #namespace = ""
  path          = vault_mount.mount_transform.path
  name          = "bankacctnum"
  type          = "fpe"
  template      = "bankacctnum"
  tweak_source  = "internal"
  allowed_roles = ["payments"]
}

resource "vault_transform_template" "name" {
  #namespace = ""
  path           = vault_transform_alphabet.numerics.path
  name           = "name"
  type           = "regex"
  pattern        = "(^.*)"
  alphabet       = "customalphanumerics"
}

resource "vault_transform_transformation" "name" {
  #namespace = ""
  path          = vault_mount.mount_transform.path
  name          = "name"
  type          = "fpe"
  template      = "name"
  tweak_source  = "internal"
  allowed_roles = ["payments"]
}

resource "vault_transform_alphabet" "customalphanumerics" {
  #namespace = ""
  path      = vault_mount.mount_transform.path
  name      = "customalphanumerics"
  alphabet  = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 @"
}

resource "vault_transform_alphabet" "email" {
  #namespace = ""
  path      = vault_mount.mount_transform.path
  name      = "email"
  alphabet  = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 @.-_"
}


# #TODO: research misleading doc in registry
data "vault_transform_encode" "test" {
    path        = vault_transform_role.payments.path
    role_name   = "payments"
    batch_input = [{"value":"111-22-3333"}]
    transformation = vault_transform_transformation.ssn.name
}