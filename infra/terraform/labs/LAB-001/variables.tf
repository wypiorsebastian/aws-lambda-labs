variable "aws_region" {
  type        = string
  description = "AWS region for the lab"
  default     = "eu-central-1"
}

variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
  default     = "health-function-lab001"
}

variable "zip_path" {
  type        = string
  description = "Path to the compiled Lambda deployment package (.zip)"
  default     = "../../../../function.zip"
}
