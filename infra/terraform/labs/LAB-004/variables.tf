variable "aws_region" {
  type        = string
  description = "Region AWS dla zasobów laba (Project decision: eu-central-1)."
  default     = "eu-central-1"
}

variable "lab_tags" {
  type        = map(string)
  description = "Wspólne tagi kosztowe/organizacyjne — TODO(lab-004): uzupełnij wg standardu swojego konta."
  default     = {}
}
