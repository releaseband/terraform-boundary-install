
resource "kubernetes_deployment" "deployment" {
  depends_on = [kubernetes_namespace.namespace, kubernetes_stateful_set.postgres]
  metadata {
    name = "boundary"
    labels = {
      "app"     = "boundary"
      "service" = "main"
    }
    namespace = "boundary"
  }
  spec {
    replicas = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        "app"     = "boundary"
        "service" = "main"
      }
    }
    template {
      metadata {
        labels = {
          "app"     = "boundary"
          "service" = "main"
        }
        annotations = {
          "vault.hashicorp.com/agent-inject"               = "true"
          "vault.hashicorp.com/agent-init-first"           = "true"
          "vault.hashicorp.com/agent-inject-secret-main"   = "secrets/boundary/main"
          "vault.hashicorp.com/role"                       = "boundary"
          "vault.hashicorp.com/agent-limits-cpu"           = 0.05
          "vault.hashicorp.com/agent-requests-cpu"         = 0.01
          "vault.hashicorp.com/agent-pre-populate-only"    = "true"
          "vault.hashicorp.com/agent-inject-template-main" = <<-EOF
          {{- with secret "secrets/boundary/main" -}}
disable_mlock = true
controller {
  name = "controller-1"
  database {
    url = "postgresql://boundary:{{ .Data.postgres_pass }}@postgres:5432/boundary?sslmode=disable"
  }
}
  kms "awskms" {
  purpose    = "root"
  region     = "${data.aws_region.current.name}"
  access_key = "{{ .Data.access_key_id }}"
  secret_key = "{{ .Data.access_key_secret }}"
  kms_key_id = "{{ .Data.aws_kms_key_id }}"
}
  kms "awskms" {
  purpose    = "worker-auth"
  region     = "${data.aws_region.current.name}"
  access_key = "{{ .Data.access_key_id }}"
  secret_key = "{{ .Data.access_key_secret }}"
  kms_key_id = "{{ .Data.aws_kms_key_id }}"
}
  kms "awskms" {
  purpose    = "recovery"
  region     = "${data.aws_region.current.name}"
  access_key = "{{ .Data.access_key_id }}"
  secret_key = "{{ .Data.access_key_secret }}"
  kms_key_id = "{{ .Data.aws_kms_key_id }}"
}
worker {
  name = "demo-worker-1"
  controllers = [
    "127.0.0.1",
  ]
  address = "127.0.0.1"
  public_addr = "boundary.${var.domain_name}"
}

listener "tcp" {
  address = "0.0.0.0"
  purpose = "api"
  tls_disable = true 
}

listener "tcp" {
  address = "127.0.0.1"
  purpose = "cluster"
  tls_disable   = true 
}
listener "tcp" {
  address = "0.0.0.0"
  purpose = "proxy"
  tls_disable   = true 
}
          {{- end }}
          EOF
        }
      }

      spec {
        container {
          image             = var.boundary_image
          image_pull_policy = "Always"
          name              = "boundary"
          args              = ["server", "-config", "/vault/secrets/main"]
          resources {
            limits = {
              cpu    = "200m"
              memory = "500M"
            }
            requests = {
              cpu    = "10m"
              memory = "60M"
            }
          }
          env {
            name  = "SKIP_SETCAP"
            value = true
          }
          port {
            protocol       = "TCP"
            container_port = 9200
          }
          port {
            protocol       = "TCP"
            container_port = 9201
          }
          port {
            protocol       = "TCP"
            container_port = 9202
          }
          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = true
            run_as_non_root            = true
            run_as_user                = 1000
            capabilities {
              drop = ["ALL"]
            }
          }
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
            read_only  = false
          }
        }
        init_container {
          image             = var.boundary_image
          image_pull_policy = "Always"
          name              = "boundary-init"
          command           = ["/bin/sh"]
          args              = ["-c", "/bin/boundary database init  -skip-host-resources-creation -skip-scopes-creation  -skip-target-creation -skip-auth-method-creation -skip-initial-login-role-creation -config /vault/secrets/main && /bin/boundary database migrate -config /vault/secrets/main || true"]
          port {
            protocol       = "TCP"
            container_port = 9200
          }
          port {
            protocol       = "TCP"
            container_port = 9201
          }
          port {
            protocol       = "TCP"
            container_port = 9202
          }
          security_context {
            read_only_root_filesystem  = true
            run_as_user                = 1000
            allow_privilege_escalation = false
            privileged                 = false
            run_as_non_root            = true
            run_as_group               = 2000
            capabilities {
              drop = ["ALL"]
            }
          }
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
            read_only  = false
          }
        }
        volume {
          name = "tmp"
          empty_dir {}
        }
        service_account_name            = "boundary"
        automount_service_account_token = true
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "beta.kubernetes.io/instance-type"
                  operator = "NotIn"
                  values   = ["t3a.small"]
                }
                match_expressions {
                  key      = "func"
                  operator = "In"
                  values   = ["system-${var.eks_cluster_name}"]
                }
              }
            }
          }
        }
      }
    }
  }
}
