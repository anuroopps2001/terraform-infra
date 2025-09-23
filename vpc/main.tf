
# Fetch the AZ's in the us-east-2 region
data "aws_availability_zones" "available" {}

# limit AZs to the number of public CIDRs provided
locals {
  # gives the list/tuple which we can with count.index to access the value at specific index
  azs_limited = slice(data.aws_availability_zones.available.names, 0, length(var.public_subnet_cidrs))

  # gives the number, which we cannot use with count.index to access the value at specific index
  azs_count = length(local.azs_limited)
}

# VPC creation with specified CIDR range
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Project VPC"
  }
}

# public subnets
resource "aws_subnet" "public_subnets" {
  count             = local.azs_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = local.azs_limited[count.index]
  tags = {
    Name = "Public subnet ${count.index + 1}"
    Type = "public"
  }
}

# private subnets
resource "aws_subnet" "private_subnet" {
  count             = local.azs_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = local.azs_limited[count.index]
  tags = {
    Name = "Private subnet ${count.index + 1}"
    Type = "private"
  }
}


# Internet gateway to provide internet access to the public subnet servers

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Project VPC IG"
  }
}


# Route table to allow traffic to reach internet through the IGW


# Whoever want to reach 0.0.0.0/0 (internet), it has to reach OGW first
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "2nd Route Table"
  }
}


# specifing the specific subnets as public subnets
resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.example.id
}



