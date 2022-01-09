provider "aws" {
  region = var.region
}

#---Creating VPC and (public-private) subnets for our network-----
resource "aws_vpc" "VPC" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "VPC_MAIN"
  }
}
resource "aws_internet_gateway" "IGW" { #--internet getaway for vpc
  vpc_id = aws_vpc.VPC.id

  tags = {
    Name = "IGW_VPC_MAIN"
  }
}

resource "aws_subnet" "Public-A" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_subnet-A"
  }
}

resource "aws_subnet" "Public-B" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "10.0.20.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_subnet-B"
  }
}
resource "aws_subnet" "Public-C" {
  vpc_id                  = aws_vpc.VPC.id
  cidr_block              = "10.0.30.0/24"
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true
  tags = {
    Name = "Public_subnet-C"
  }
}
resource "aws_subnet" "Private-A" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.0.110.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "Private_subnet-A"
  }
}
resource "aws_subnet" "Private-B" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.0.120.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "Private_subnet-B"
  }
}
resource "aws_subnet" "Private-C" {
  vpc_id            = aws_vpc.VPC.id
  cidr_block        = "10.0.130.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "Private_subnet-C"
  }
}

#---Create rout table and add rout to internet gateway -----

resource "aws_route_table" "VPC_Public_Route" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "VPC_Public_Route"
  }
}
resource "aws_route_table" "VPC_Private_Route" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "VPC_Private_Route"
  }
}
resource "aws_route_table_association" "Association_Private_A" {
  subnet_id      = aws_subnet.Private-A.id
  route_table_id = aws_route_table.VPC_Private_Route.id
}
resource "aws_route_table_association" "Association_Private_B" {
  subnet_id      = aws_subnet.Private-B.id
  route_table_id = aws_route_table.VPC_Private_Route.id
}
resource "aws_route_table_association" "Association_Private_C" {
  subnet_id      = aws_subnet.Private-C.id
  route_table_id = aws_route_table.VPC_Private_Route.id
}
resource "aws_route_table_association" "Association_Public_A" {
  subnet_id      = aws_subnet.Public-A.id
  route_table_id = aws_route_table.VPC_Public_Route.id
}
resource "aws_route_table_association" "Association_Public_B" {
  subnet_id      = aws_subnet.Public-B.id
  route_table_id = aws_route_table.VPC_Public_Route.id
}
resource "aws_route_table_association" "Association_Public_C" {
  subnet_id      = aws_subnet.Public-C.id
  route_table_id = aws_route_table.VPC_Public_Route.id
}
#-------------------------------------------------------------------
resource "aws_security_group" "SG_EC2_Ruby" {
  name   = "SG_EC2_Ruby"
  vpc_id = aws_vpc.VPC.id

  dynamic "ingress" {
    for_each = ["80", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG_EC2_Ruby"
  }
}
resource "aws_instance" "EC2_Ruby" {
  ami                    = data.aws_ami.latest_ubuntu.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Public-A.id
  vpc_security_group_ids = [aws_security_group.SG_EC2_Ruby.id]
  key_name               = data.aws_key_pair.Frankfurt_key.key_name
  user_data              = file("UserData.sh")
  tags = {
    Name = "EC2_Ruby"
  }
}