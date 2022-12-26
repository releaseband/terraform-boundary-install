resource "kubernetes_stateful_set" "postgres" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = "postgres"
    namespace = "boundary"
    labels = {
      "app"     = "boundary"
      "service" = "postgres"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app"     = "boundary"
        "service" = "postgres"
      }
    }
    template {
      metadata {
        labels = {
          "app"     = "boundary"
          "service" = "postgres"
        }
        annotations = {
          "vault.hashicorp.com/agent-inject"                   = "true"
          "vault.hashicorp.com/agent-init-first"               = "true"
          "vault.hashicorp.com/agent-inject-secret-postgres"   = "secrets/boundary/main"
          "vault.hashicorp.com/role"                           = "boundary"
          "vault.hashicorp.com/agent-limits-cpu"               = 0.05
          "vault.hashicorp.com/agent-requests-cpu"             = 0.01
          "vault.hashicorp.com/agent-pre-populate-only"        = "true"
          "vault.hashicorp.com/agent-inject-template-postgres" = <<-EOF
          {{- with secret "secrets/boundary/main" -}}
          {{ .Data.postgres_pass }}
          {{- end }}
          EOF
        }
      }
      spec {
        container {
          name              = "postgres"
          image             = var.postgres_image
          image_pull_policy = "Always"
          resources {
            limits = {
              cpu    = "200m"
              memory = "200M"
            }
            requests = {
              cpu    = "10m"
              memory = "100M"
            }
          }
          port {
            name           = "postgres"
            container_port = 5432
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
          env_from {
            config_map_ref { name = "postgres" }
          }
          volume_mount {
            name       = "postgres"
            mount_path = "/var/lib/postgresql/data"
          }
          volume_mount {
            name       = "run"
            mount_path = "/var/run/postgresql"
            read_only  = false
          }
          volume_mount {
            name       = "tmp"
            mount_path = "/tmp"
            read_only  = false
          }
        }
        init_container {
          name              = "init"
          image             = var.shell_image
          image_pull_policy = "Always"
          command           = ["/bin/sh"]
          args              = ["-c", "chown -R 1000:1000 /var/lib/postgresql/data"]
          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = true
            capabilities {
              drop = ["ALL"]
              add  = ["CHOWN", "DAC_OVERRIDE", "FOWNER"]
            }
          }
          volume_mount {
            name       = "postgres"
            mount_path = "/var/lib/postgresql/data"
          }
        }
        volume {
          name = "run"
          empty_dir {}
        }
        volume {
          name = "tmp"
          empty_dir {}
        }
        termination_grace_period_seconds = 120
        service_account_name             = "boundary"
        automount_service_account_token  = true
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
    update_strategy {
      type = "RollingUpdate"
    }
    volume_claim_template {
      metadata {
        name = "postgres"
      }
      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "gp3-resized"
        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }
    service_name = "postgres"
  }
}
