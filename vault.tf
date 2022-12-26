
resource "random_password" "postgres_user_pass" {
  length  = 16
  special = false
}

resource "vault_generic_secret" "main" {
  path = "secrets/boundary/main"

  data_json = <<EOT
{
  "postgres_pass":"${random_password.postgres_user_pass.result}",
  "aws_kms_key_id":"${aws_kms_key.boundary.key_id}",
  "access_key_id":"${aws_iam_access_key.boundary_access_key.id}",
  "access_key_secret":"${aws_iam_access_key.boundary_access_key.secret}"
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "boundary" {
  backend                          = "kubernetes/"
  role_name                        = "boundary"
  bound_service_account_names      = ["boundary"]
  bound_service_account_namespaces = ["boundary"]
  token_ttl                        = 3600
  token_policies                   = ["boundary"]
}


resource "vault_policy" "timescale_policy" {
  name = "boundary"

  policy = <<EOT
path "secrets/boundary/*" {
  capabilities = ["read"]
}
EOT
}
