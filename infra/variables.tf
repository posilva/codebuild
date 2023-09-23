variable "aws_region" {
  description = "aws region"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "AWS Profile"
  default     = null
}