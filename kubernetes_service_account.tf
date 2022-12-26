resource "kubernetes_service_account" "account" {
  depends_on = [kubernetes_namespace.namespace]
  metadata {
    name      = "boundary"
    namespace = "boundary"
    labels = {
      "app" = "boundary"
    }
  }
}
