provider "vault" {
  address = "https://vault.${var.domain_name}/"
  token   = var.vault_token
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}


terraform {
required_version = "1.3.6"
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.16.1"
    }
    random = {
      source = "hashicorp/random"
      version = "3.4.3"
    }
    aws = {
      source = "hashicorp/aws"
      version = "4.48.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "3.11.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.8.0"
    }
  }
}