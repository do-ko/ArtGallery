output "image_digest" { value = data.aws_ecr_image.this.image_digest }
output "image_ref"    { value = "${var.repo_url}@${data.aws_ecr_image.this.image_digest}" }