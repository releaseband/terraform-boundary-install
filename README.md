## Upgrading Chart
### From 1.x to 2.x

```console
terraform state mv module.foundation.module.boundary.kubernetes_service.boundary module.foundation.module.boundary.kubernetes_service.main
terraform state mv module.foundation.module.boundary.vault_policy.timescale_policy module.foundation.module.boundary.vault_policy.main
terraform state mv  module.foundation.module.boundary.vault_kubernetes_auth_backend_role.boundary  module.foundation.module.boundary.vault_kubernetes_auth_backend_role.main
terraform state mv module.foundation.module.boundary.random_password.postgres_user_pass module.foundation.module.boundary.random_password.main
terraform state mv module.foundation.module.boundary.kubernetes_service_account.account  module.foundation.module.boundary.kubernetes_service_account.main
terraform state mv module.foundation.module.boundary.kubernetes_namespace.namespace module.foundation.module.boundary.kubernetes_namespace.main
terraform state mv module.foundation.module.boundary.kubernetes_limit_range.global module.foundation.module.boundary.kubernetes_limit_range.main
terraform state mv module.foundation.module.boundary.kubernetes_deployment.deployment module.foundation.module.boundary.kubernetes_deployment.main
terraform state mv module.foundation.module.boundary.kubernetes_config_map.hasura_config_map module.foundation.module.boundary.kubernetes_config_map.main
terraform state mv module.foundation.module.boundary.aws_route53_record.route53 module.foundation.module.boundary.aws_route53_record.main
terraform state mv module.foundation.module.boundary.aws_kms_key.boundary  module.foundation.module.boundary.aws_kms_key.main
terraform state mv module.foundation.module.boundary.aws_iam_user_policy.iam_user_policy module.foundation.module.boundary.aws_iam_user_policy.main
terraform state mv module.foundation.module.boundary.aws_iam_user.boundary_iam_user module.foundation.module.boundary.aws_iam_user.main
terraform state mv module.foundation.module.boundary.aws_iam_access_key.boundary_access_key  module.foundation.module.boundary.aws_iam_access_key.main
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.48 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.8 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.16 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 3.11 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.48 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.16 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | >= 3.11 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_access_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_access_key) | resource |
| [aws_iam_user.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy) | resource |
| [aws_kms_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_route53_record.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [kubernetes_config_map.postgres](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map) | resource |
| [kubernetes_deployment.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment) | resource |
| [kubernetes_limit_range.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/limit_range) | resource |
| [kubernetes_namespace.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_service.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service.postgres](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service) | resource |
| [kubernetes_service_account.main](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_stateful_set.postgres](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/stateful_set) | resource |
| [random_password.main](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [vault_generic_secret.main](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/generic_secret) | resource |
| [vault_kubernetes_auth_backend_role.main](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kubernetes_auth_backend_role) | resource |
| [vault_policy.main](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [aws_acm_certificate.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lb) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [kubernetes_service.nlb](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/service) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_boundary_image"></a> [boundary\_image](#input\_boundary\_image) | Boundary image | `string` | `"hashicorp/boundary:0.11"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Domain for dns records | `string` | n/a | yes |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of EKS cluster for provider config and nodeselectors | `string` | n/a | yes |
| <a name="input_postgres_image"></a> [postgres\_image](#input\_postgres\_image) | Postgres image | `string` | `"postgres:13.8"` | no |
| <a name="input_shell_image"></a> [shell\_image](#input\_shell\_image) | Shell image for pvc fix | `string` | `"bitnami/bitnami-shell:10-debian-10"` | no |
| <a name="input_vault_token"></a> [vault\_token](#input\_vault\_token) | Token for vault provider | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_key_id"></a> [access\_key\_id](#output\_access\_key\_id) | aws access key id for boundary config module |
| <a name="output_access_key_secret"></a> [access\_key\_secret](#output\_access\_key\_secret) | aws key secret for boundary config module |
| <a name="output_aws_kms_key_id"></a> [aws\_kms\_key\_id](#output\_aws\_kms\_key\_id) | kms key id for boundary config module |
<!-- END_TF_DOCS -->