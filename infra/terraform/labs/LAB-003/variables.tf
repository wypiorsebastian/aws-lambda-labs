variable "aws_region" {
  type        = string
  description = "Region AWS dla laba"
  default     = "eu-central-1"
}

variable "app_env" {
  type        = string
  description = "Etykieta środowiska (nie jest sekretem) — trafia do zmiennej środowiskowej APP_ENV"
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.app_env)
    error_message = "app_env musi być jednym z: dev, test, staging, prod (uproszczenie dla laba)."
  }
}

variable "public_feature_toggle" {
  type        = string
  description = "Przykład niepoufnej flagi konfiguracyjnej w env (wartość jawna)"
  default     = "true"
}
