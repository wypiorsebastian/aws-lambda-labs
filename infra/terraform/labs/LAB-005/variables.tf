variable "aws_region" {
  type        = string
  description = "Region AWS dla zasobów LAB-005 (Project decision: eu-central-1)."
  default     = "eu-central-1"
}

variable "authorizer_cache_ttl_seconds" {
  type        = number
  description = "TTL cache decyzji authorizera; 0 oznacza brak cache (Simplification for this lab)."
  default     = 0
}

variable "lab_tags" {
  type        = map(string)
  description = "Wspólne tagi kosztowe/organizacyjne — TODO(lab-005): uzupełnij według standardu konta."
  default     = {}
}
