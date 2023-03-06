variable "eks_cluster_name" {
  description = "Name of EKS cluster for provider config and nodeselectors"
  type        = string
}

variable "vault_token" {
  description = "Token for vault provider"
  type        = string
}




variable "domain_name" {
  description = "Domain for dns records"
  type        = string
}

variable "boundary_image" {
  default     = "hashicorp/boundary:0.11"
  description = "Boundary image"
  type        = string
}

variable "postgres_image" {
  default     = "postgres:13.8"
  description = "Postgres image"
  type        = string
}

variable "shell_image" {
  default     = "bitnami/bitnami-shell:10-debian-10"
  description = "Shell image for pvc fix"
  type        = string
}

