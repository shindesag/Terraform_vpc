resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
  
    tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  count = var.subnet_external == true ? 1 : 0
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "nat" {
  #vpc   = true
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id     = aws_eip.nat.id
  subnet_id         = aws_subnet.public[0].id
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count            = var.no_of_public_subnets
  vpc_id           = aws_vpc.main.id
  cidr_block       = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone= element(data.aws_availability_zones.available.names, count.index)
  
  tags = {
    Name = "Subnet-Public-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count            = var.no_of_private_subnets
  vpc_id           = aws_vpc.main.id
  cidr_block       = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 100)
  availability_zone= element(data.aws_availability_zones.available.names, count.index)
  
  tags = {
    Name = "Subnet-Private-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw[0].id
  }

  tags = {
    Name = "Public_Route"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.no_of_public_subnets
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table" "private" {
  vpc_id          = aws_vpc.main.id
  
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private_Route"
  }
}


resource "aws_route_table_association" "private" {
  count          = var.no_of_private_subnets
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}


resource "aws_security_group" "default" {
  description = "Allow all inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.main.id
 
  ingress {
   from_port   = 0
   to_port     = 0
   protocol    = -1
   self        = "false"
   cidr_blocks = ["0.0.0.0/0"]
   description = "any"
 }

 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
  tags = {
    Name = "default"
  }
}



