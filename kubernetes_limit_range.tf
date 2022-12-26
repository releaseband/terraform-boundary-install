resource "kubernetes_limit_range" "global" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = "boundary"
    namespace = "boundary"
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
