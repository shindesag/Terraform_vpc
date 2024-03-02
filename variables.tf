variable "vpc_name" {
  type        = string
  default     = "Sample-VPC"
}

variable "cidr_block" {
  type        = string
  #default     = "10.0.0.0/16"
}

variable "subnet_external" {
  type        = bool
  default     = true
}

variable "no_of_public_subnets" {
  type        = number
  #default     = 0
}

variable "no_of_private_subnets" {
  type        = number
  #default     = 0
}
