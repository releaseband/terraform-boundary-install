resource "kubernetes_config_map" "hasura_config_map" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = "postgres"
    namespace = "boundary"
  }

  data = {
    "POSTGRES_DB"            = "boundary"
    "POSTGRES_USER"          = "boundary"
    "POSTGRES_PASSWORD_FILE" = "/vault/secrets/postgres"
    "PGDATA"                 = "/var/lib/postgresql/data/pgdata"
  }
}



