
locals {
  app = "boundary"
}

resource "kubernetes_namespace" "main" {
  metadata {
    labels = {
      name = local.app
    }
    name = local.app
    annotations = {
      "linkerd.io/inject"                  = "enabled"
      "config.linkerd.io/proxy-await"      = "enabled"
      "config.linkerd.io/proxy-log-format" = "json"
    }
  }
}

resource "kubernetes_service_account" "main" {
  metadata {
    name      = local.app
    namespace = kubernetes_namespace.main.metadata[0].name
    labels = {
      "app" = local.app
    }
  }
}


resource "kubernetes_deployment" "main" {
  depends_on = [kubernetes_stateful_set.postgres]
  metadata {
    name = local.app
    labels = {
      "app"     = local.app
      "service" = "main"
    }
    namespace = kubernetes_namespace.main.metadata[0].name
  }
  spec {
    replicas = 1
    strategy {
      type = "Recreate"
    }
    selector {
      match_labels = {
        "app"     = local.app
        "service" = "main"
      }
    }
    template {
      metadata {
        labels = {
          "app"     = local.app
          "service" = "main"
        }
        annotations = {
          "vault.hashicorp.com/agent-inject"               = "true"
          "vault.hashicorp.com/agent-init-first"           = "true"
          "vault.hashicorp.com/agent-inject-secret-main"   = "secrets/boundary/main"
          "vault.hashicorp.com/role"                       = local.app
          "vault.hashicorp.com/agent-limits-cpu"           = 0.05
          "vault.hashicorp.com/agent-requests-cpu"         = 0.01
          "vault.hashicorp.com/agent-pre-populate-only"    = "true"
          "vault.hashicorp.com/agent-inject-template-main" = <<-EOF
          {{- with secret "secrets/boundary/main" -}}
disable_mlock = true
controller {
  name = "controller-1"
  auth_token_time_to_live  = "240h"
  auth_token_time_to_stale = "72h"
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
          "config.linkerd.io/proxy-cpu-request"            = "2m"
          "config.linkerd.io/proxy-cpu-limit"              = "4m"
          "config.linkerd.io/proxy-memory-request"         = "10Mi"
          "config.linkerd.io/proxy-memory-limit"           = "20Mi"
        }
      }

      spec {
        container {
          image             = var.boundary_image
          image_pull_policy = "Always"
          name              = local.app
          args              = ["server", "-config", "/vault/secrets/main"]
          resources {
            limits = {
              cpu    = var.boundary_resources.limits.cpu
              memory = var.boundary_resources.limits.memory
            }
            requests = {
              cpu    = var.boundary_resources.requests.cpu
              memory = var.boundary_resources.requests.memory
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
        service_account_name            = kubernetes_service_account.main.metadata[0].name
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

resource "aws_kms_key" "main" {
  description = local.app
}

resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.main.id
  name    = local.app
  type    = "A"

  alias {
    name                   = data.kubernetes_service.main.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_lb.nlb.zone_id
    evaluate_target_health = true
  }
}

resource "kubernetes_limit_range" "main" {
  metadata {
    name      = local.app
    namespace = kubernetes_namespace.main.metadata[0].name
  }
  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "200m"
        memory = "500M"
      }
      default_request = {
        cpu    = "10m"
        memory = "100M"
      }
    }
  }
}

resource "kubernetes_config_map" "main" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.main.metadata[0].name
  }

  data = {
    "POSTGRES_DB"            = local.app
    "POSTGRES_USER"          = local.app
    "POSTGRES_PASSWORD_FILE" = "/vault/secrets/postgres"
    "PGDATA"                 = "/var/lib/postgresql/data/pgdata"
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.main.metadata[0].name
    labels = {
      "app"     = local.app
      "service" = "postgres"
    }
  }
  spec {
    port {
      name        = "postgres"
      port        = 5432
      target_port = "5432"
    }
    selector = {
      "app"     = local.app
      "service" = "postgres"
    }
    cluster_ip = "None"
  }
}



resource "aws_iam_access_key" "main" {
  user = aws_iam_user.main.name
}


resource "aws_iam_user" "main" {
  name = local.app
}

resource "aws_iam_user_policy" "main" {
  name = local.app
  user = aws_iam_user.main.name

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
{
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:DescribeKey"
      ],
      "Resource": "*"
    }
  ]
}
POLICY
}


resource "random_password" "main" {
  length  = 16
  special = false
}

resource "vault_generic_secret" "main" {
  path = "secrets/boundary/main"

  data_json = <<EOT
{
  "postgres_pass":"${random_password.main.result}",
  "aws_kms_key_id":"${aws_kms_key.main.key_id}",
  "access_key_id":"${aws_iam_access_key.main.id}",
  "access_key_secret":"${aws_iam_access_key.main.secret}"
}
EOT
}

resource "vault_kubernetes_auth_backend_role" "main" {
  backend                          = "kubernetes/"
  role_name                        = local.app
  bound_service_account_names      = [local.app]
  bound_service_account_namespaces = [local.app]
  token_ttl                        = 3600
  token_policies                   = [local.app]
}


resource "vault_policy" "main" {
  name = local.app

  policy = <<EOT
path "secrets/boundary/*" {
  capabilities = ["read"]
}
EOT
}

resource "kubernetes_service" "main" {
  metadata {
    name      = local.app
    namespace = kubernetes_namespace.main.metadata[0].name

    labels = {
      "app" = local.app
    }
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                    = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-cert"                = data.aws_acm_certificate.main.arn
      "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"        = "http"
      "service.beta.kubernetes.io/aws-load-balancer-proxy-protocol"          = "*"
      "service.beta.kubernetes.io/aws-load-balancer-connection-idle-timeout" = "3600"
      "service.beta.kubernetes.io/aws-load-balancer-ssl-ports"               = "443"
    }
  }
  spec {
    port {
      name        = "controller"
      port        = 443
      target_port = "9200"
    }
    port {
      name        = "api"
      port        = 9201
      target_port = "9201"
    }
    port {
      name        = "worker"
      port        = 9202
      target_port = "9202"
    }
    type = "LoadBalancer"
    selector = {
      "app"     = local.app
      "service" = "main"
    }
    external_traffic_policy = "Local"
  }
}

resource "kubernetes_stateful_set" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.main.metadata[0].name
    labels = {
      "app"     = local.app
      "service" = "postgres"
    }
    annotations = {
      "polaris.fairwinds.com/runAsRootAllowed-exempt" = "true"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        "app"     = local.app
        "service" = "postgres"
      }
    }
    template {
      metadata {
        labels = {
          "app"     = local.app
          "service" = "postgres"
        }
        annotations = {
          "vault.hashicorp.com/agent-inject"                   = "true"
          "vault.hashicorp.com/agent-init-first"               = "true"
          "vault.hashicorp.com/agent-inject-secret-postgres"   = "secrets/boundary/main"
          "vault.hashicorp.com/role"                           = local.app
          "vault.hashicorp.com/agent-limits-cpu"               = 0.05
          "vault.hashicorp.com/agent-requests-cpu"             = 0.01
          "vault.hashicorp.com/agent-pre-populate-only"        = "true"
          "vault.hashicorp.com/agent-inject-template-postgres" = <<-EOF
          {{- with secret "secrets/boundary/main" -}}
          {{ .Data.postgres_pass }}
          {{- end }}
          EOF
          "config.linkerd.io/proxy-cpu-request"                = "2m"
          "config.linkerd.io/proxy-cpu-limit"                  = "4m"
          "config.linkerd.io/proxy-memory-request"             = "10Mi"
          "config.linkerd.io/proxy-memory-limit"               = "20Mi"
        }
      }
      spec {
        container {
          name              = "postgres"
          image             = var.postgres_image
          image_pull_policy = "Always"
          resources {
            limits = {
              cpu    = var.postgres_resources.limits.cpu
              memory = var.postgres_resources.limits.memory
            }
            requests = {
              cpu    = var.postgres_resources.requests.cpu
              memory = var.postgres_resources.requests.memory
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
        service_account_name             = kubernetes_service_account.main.metadata[0].name
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
