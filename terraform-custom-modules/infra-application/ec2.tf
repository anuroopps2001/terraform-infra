# key pair
resource "aws_key_pair" "deployer" {
  key_name   = "${var.env}-infra-kp"
  public_key = file("../ec2/id_rsa.pub")
}

# vpc
resource "aws_default_vpc" "default" {

}

# Security Group
resource "aws_security_group" "my_security_group" {
  name        = local.security_group_name
  description = "This will add an tf generated security group"
  vpc_id      = aws_default_vpc.default.id #interpolation (it is a way in which we can extract the values from an any terraform block)

  #Inbound roues (ingress)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh open"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "http open"
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "flask app"
  }

  #Outbound rules (egress)  
  egress {
    from_port   = 0    # all ports
    to_port     = 0    # all ports
    protocol    = "-1" #all protocol
    cidr_blocks = ["0.0.0.0/0"]
    description = "all access"
  }
  tags = {
    Name = local.security_group_name
  }
}

# local variables
locals {
  sg_id = var.shared_sg_id   # if using lookup later, fill fallback

  security_group_name = terraform.workspace == "default" ? format("%s-%s-%s", var.env, data.aws_caller_identity.current.account_id, local.sg_id) : format("%s-%s-%s", terraform.workspace, data.aws_caller_identity.current.account_id, local.sg_id)
}


# ec2 instance

resource "aws_instance" "my_instance" {
  count = var.instance_count
  # depends_on is also an meta arguement
  depends_on      = [aws_security_group.my_security_group, aws_key_pair.deployer]
  key_name        = aws_key_pair.deployer.key_name              # interpolcation
  security_groups = [aws_security_group.my_security_group.name] # interpolation
  instance_type   = var.instance_type
  ami             = var.ec2_ami_id                  # ubuntu in us-east-2
  user_data       = file("../ec2/install_nginx.sh") # to input something into the instance ASAP, the instance gets started through the scripts

  root_block_device {
    volume_size = var.env == "default" ? 10 : 11 # ternary operator in terms on programming OR conditional statements in terraform
    volume_type = "gp3"                                 # gp=General Purpose
  }

  tags = {
    Name = "${var.env}-infra-instance"
  }
}