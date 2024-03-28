data "kubernetes_service" "main" {
  depends_on = [kubernetes_service.main]
  metadata {
    name      = local.app
    namespace = kubernetes_namespace.main.metadata[0].name
  }
}

data "aws_lb" "nlb" {
  name = local.nlb_hostname
}

locals {
  nlb_hostname = regex("[^-/?#]+", data.kubernetes_service.main.status[0].load_balancer[0].ingress[0].hostname)
}

data "aws_route53_zone" "main" {
  name = var.domain_name
}

data "aws_region" "current" {}

data "aws_acm_certificate" "main" {
  domain = var.domain_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.eks_cluster_name
}
data "aws_eks_cluster" "cluster" {
  name = var.eks_cluster_name
}