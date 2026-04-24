variable "aws_region" {
  type        = string
  description = "Region AWS dla zasobów LAB-010 (Project decision: eu-central-1)."
  default     = "eu-central-1"
}

variable "lambda_log_retention_days" {
  type        = number
  description = "Retencja logów CloudWatch dla funkcji Lambda."
  default     = 14
}

variable "lab_tags" {
  type        = map(string)
  description = "Wspólne tagi kosztowe/organizacyjne. TODO(lab-010): uzupełnij wg standardu konta."
  default     = {}
}
