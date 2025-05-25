resource "aws_batch_compute_environment" "aws_batch_compute_environment" {
  for_each = var.locations
  region = each.key
  name = "${var.project_name}-batch-compute-environment-${each.key}"
  type = "MANAGED"
}