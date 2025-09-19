# key pair
resource "aws_key_pair" "deployer" {
  key_name   = "id_rsa"
  public_key = file("./id_rsa.pub")
}

# vpc
resource "aws_default_vpc" "default" {

}

# Security Group
resource "aws_security_group" "my_security_group" {
  name        = "automate-sg"
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
    name = "automate-sg"
  }
}

# ec2 instance

resource "aws_instance" "my_instance" {
  # count = 2 # It is an meta arguement

  # using for each meta arguement
  for_each = tomap({
    tws-junoon-automate-micro  = "t2.micro"
    tws-junoon-automate-medium = "t2.medium"
  })

  # depends_on is also an meta arguement
  depends_on      = [aws_security_group.my_security_group, aws_key_pair.deployer]
  key_name        = aws_key_pair.deployer.key_name              # interpolcation
  security_groups = [aws_security_group.my_security_group.name] # interpolation
  instance_type   = each.value
  ami             = var.ec2_ami_id           # ubuntu in us-east-2
  user_data       = file("install_nginx.sh") # to input something into the instance ASAP, the instance gets started through the scripts

  root_block_device {
    volume_size = var.env == "uat" ? var.ec2_root_disK_size : 10 # ternary operator in terms on programming OR conditional statements in terraform
    volume_type = "gp3"                                          # gp=General Purpose
  }

  tags = {
    Name = each.key
  }
}


# Importing resources created manually into terraform
resource "aws_instance" "my_new_instance" {
  ami = "ami-0cfde0ea8edd312d4"
  instance_type = "t3.micro"
}