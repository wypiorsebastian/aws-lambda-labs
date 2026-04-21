variable "aws_region" {
  type        = string
  description = "Region AWS dla zasobów LAB-006 (Project decision: eu-central-1)."
  default     = "eu-central-1"
}

variable "function_zip_path" {
  type        = string
  description = "Ścieżka (od root repo) do ZIP funkcji LAB-006."
  default     = "artifacts/LAB-006/function.zip"
}

variable "lambda_log_retention_days" {
  type        = number
  description = "Retencja logów CloudWatch dla funkcji Lambda."
  default     = 14
}

variable "api_access_log_retention_days" {
  type        = number
  description = "Retencja access logów API Gateway."
  default     = 14
}

variable "lab_tags" {
  type        = map(string)
  description = "Wspólne tagi kosztowe/organizacyjne — TODO(lab-006): uzupełnij wg standardu konta."
  default     = {}
}
