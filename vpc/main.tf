resource "aws_vpc" "terraform-vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terraform-vpc"
  }
}

resource "aws_subnet" "first-aws-subnet" {
  vpc_id = aws_vpc.terraform-vpc.id
  cidr_block = "10.0.1.0/24"
  

  tags = {
    Name = "first-aws-subnet"
  }
}

resource "aws_subnet" "second-aws-subnet" {
  vpc_id = aws_vpc.terraform-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "second-aws-subnet"
  }
}

resource "aws_internet_gateway" "terraform-igw" {
  vpc_id = aws_vpc.terraform-vpc.id


  tags = {
    Name = "terraform-igw"
  }
}

resource "aws_route_table" "terraform-route-table" {
  vpc_id = aws_vpc.terraform-vpc.id

  route = {
    cidr_block = "10.0.1.0/24"
    gateway_id = aws_internet_gateway.terraform-igw.id
  }

  tags = {
    Name = "terraform-RT"
  }
}

resource "aws_route_table_association" "terraform-RT-association" {
  subnet_id = aws_subnet.first-aws-subnet.id
  route_table_id = aws_route_table.terraform-route-table.id  
}


# NAT-GW creation

resource "aws_nat_gateway" "terraform-nat-gw" {
  connectivity_type = "private"
  subnet_id = aws_subnet.second-aws-subnet.id
}

resource "aws_route_table" "terraform-private-RT" {
  vpc_id = aws_vpc.terraform-vpc.id
  route = {
    cidr_block = "10.0.2.0/24"
    gateway_id = aws_nat_gateway.id
  }

  tags = {
    Name = "terraform-private-RT"
  }
}