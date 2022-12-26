<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.3.6 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | 4.48.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | 2.8.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.16.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.4.3 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | 3.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.48.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.16.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 3.11.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.boundary_access_key](https://registry.terraform.io/providers/hashicorp/aws/4.48.0/docs/resources/iam_access_key) | resource |
| [aws_iam_user.boundary_iam_user](https://registry.terraform.io/providers/hashicorp/aws/4.48.0/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.iam_user_policy](https://registry.terraform.io/providers/hashicorp/aws/4.48.0/docs/resources/iam_user_policy) | resource |
| [aws_kms_key.boundary](https://registry.terraform.io/providers/hashicorp/aws/4.48.0/docs/resources/kms_key) | resource |
| [aws_route53_record.route53](https://registry.terraform.io/providers/hashicorp/aws/4.48.0/docs/resources/route53_record) | resource |
| [kubernetes_config_map.hasura_config_map](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/config_map) | resource |
| [kubernetes_deployment.deployment](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/deployment) | resource |
| [kubernetes_limit_range.global](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/limit_range) | resource |
| [kubernetes_namespace.namespace](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/namespace) | resource |
| [kubernetes_service.boundary](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/service) | resource |
| [kubernetes_service.postgres](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/service) | resource |
| [kubernetes_service_account.account](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/service_account) | resource |
| [kubernetes_stateful_set.postgres](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/resources/stateful_set) | resource |
| [random_password.postgres_user_pass](https://registry.terraform.io/providers/hashicorp/random/3.4.3/docs/resources/password) | resource |
| [vault_generic_secret.main](https://registry.terraform.io/providers/hashicorp/vault/3.11.0/docs/resources/generic_secret) | resource |
| [vault_kubernetes_auth_backend_role.boundary](https://registry.terraform.io/providers/hashicorp/vault/3.11.0/docs/resources/kubernetes_auth_backend_role) | resource |
| [vault_policy.timescale_policy](https://registry.terraform.io/providers/hashicorp/vault/3.11.0/docs/resources/policy) | resource |
| [aws_acm_certificate.main](https://registry.terraform.io/providers/hashicorp/aws/4.48.0/docs/data-sources/acm_certificate) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/4.48.0/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/4.48.0/docs/data-sources/eks_cluster_auth) | data source |
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/4.48.0/docs/data-sources/lb) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/4.48.0/docs/data-sources/region) | data source |
| [aws_route53_zone.main](https://registry.terraform.io/providers/hashicorp/aws/4.48.0/docs/data-sources/route53_zone) | data source |
| [kubernetes_service.nlb](https://registry.terraform.io/providers/hashicorp/kubernetes/2.16.1/docs/data-sources/service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_boundary_image"></a> [boundary\_image](#input\_boundary\_image) | Boundary image | `string` | `"hashicorp/boundary:0.11"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain for dns records | `string` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of EKS cluster for provider config and nodeselectors | `string` | n/a | yes |
| <a name="input_postgres_image"></a> [postgres\_image](#input\_postgres\_image) | Postgres image | `string` | `"postgres:13.8"` | no |
| <a name="input_shell_image"></a> [shell\_image](#input\_shell\_image) | Shell image for pvc fix | `string` | `"bitnami/bitnami-shell:10-debian-10"` | no |
| <a name="input_vault_token"></a> [vault\_token](#input\_vault\_token) | Token for vault provider | `string` | n/a | yes |
| <a name="input_wait_vault"></a> [wait\_vault](#input\_wait\_vault) | Variable for module order | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_key_id"></a> [access\_key\_id](#output\_access\_key\_id) | aws access key id for boundary config module |
| <a name="output_access_key_secret"></a> [access\_key\_secret](#output\_access\_key\_secret) | aws key secret for boundary config module |
| <a name="output_aws_kms_key_id"></a> [aws\_kms\_key\_id](#output\_aws\_kms\_key\_id) | kms key id for boundary config module |
<!-- END_TF_DOCS -->