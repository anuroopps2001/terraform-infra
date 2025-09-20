# Based on the requirement

# MAIN MODULE

#dev environment
module "dev-infra" {
  source         = "./infra-application"
  env            = "dev"
  instance_count = 1
  instance_type  = "t2.micro"
  ec2_ami_id     = "ami-0cfde0ea8edd312d4" #Ubuntu
  hash_key       = "StudentID"
  sg_name = "dev-sg"
  shared_sg_id = "sg-0abc1234def567890"
}


# staging environment
module "staging-infra" {
  source         = "./infra-application"
  env            = "staging"
  instance_count = 1
  instance_type  = "t2.small"
  ec2_ami_id     = "ami-0cfde0ea8edd312d4" #Ubuntu
  hash_key       = "StudentID"
  sg_name = "staging-sg"
  shared_sg_id = "sg-0abc1234def567890"
}


# Production environment
module "production-infra" {
  source         = "./infra-application"
  env            = "production"
  instance_count = 2
  instance_type  = "t2.medium"
  ec2_ami_id     = "ami-0cfde0ea8edd312d4" #Ubuntu
  hash_key       = "StudentID"
  sg_name = "prod-sg"
  shared_sg_id = "sg-0abc1234def567890"
}
