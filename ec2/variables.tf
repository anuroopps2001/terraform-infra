variable "ec2_instance_size" {
  default = "t2.micro"
  type    = string
}

variable "ec2_ami_id" {
  default = "ami-0cfde0ea8edd312d4" # ubuntu in us-east-2
  type    = string
}

variable "ec2_root_disK_size" {
  default = 20
  type    = number
}


# conditional statements
variable "env" {
  default = "prod"
  type    = string
}