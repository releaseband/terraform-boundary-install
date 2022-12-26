resource "kubernetes_service" "postgres" {
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
    port {
      name        = "postgres"
      port        = 5432
      target_port = "5432"
    }
    selector = {
      "app"     = "boundary"
      "service" = "postgres"
    }
    cluster_ip = "None"
  }
}
