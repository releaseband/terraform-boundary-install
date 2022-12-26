resource "kubernetes_service" "boundary" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = "boundary"
    namespace = "boundary"

    labels = {
      "app" = "boundary"
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
      "app"     = "boundary"
      "service" = "main"
    }
    external_traffic_policy = "Local"
  }
}

