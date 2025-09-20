variable "env" {
  description = "This is the environment for my infra"
  type        = string
}

variable "bucket_name" {
  description = "This is the bucket name for my infra"
  type        = string
  default     = ""
}

variable "ec2_ami_id" {
  description = "ami-id for ec2 instance"
  type        = string
}

variable "instance_count" {
  description = "This is the number of ec2 instances"
  type        = number
}

variable "instance_type" {
  description = "This is the instance type"
  type        = string
}

variable "hash_key" {
  description = "Provide the key as LockID"
  type        = string
}

variable "sg_name" {
  description = "Name of the security group to look up"
  type        = string
}

variable "shared_sg_id" {
  description = "Optional: exact SG id passed from root (sg-...)"
  type        = string
  default     = ""
}