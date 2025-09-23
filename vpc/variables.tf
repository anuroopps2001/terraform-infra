variable "public_subnet_cidrs" {
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  type        = list(string)
  description = "Public subnet CIDR values"
}

variable "private_subnet_cidrs" {
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  type        = list(string)
  description = "Private subnet CIDR values"
}