output "aws_kms_key_id" {
  value       = aws_kms_key.boundary.key_id
  description = "kms key id for boundary config module"
}

output "access_key_id" {
  value       = aws_iam_access_key.boundary_access_key.id
  description = "aws access key id for boundary config module"

}
output "access_key_secret" {
  value       = aws_iam_access_key.boundary_access_key.secret
  description = "aws key secret for boundary config module"
}
