provider "aws" {
  region = "us-east-1" # Região
}


# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "MainVpc"
  }
}

# Subnet pública
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "PublicSubnet"
  }
}

# Subnet privada
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "PrivateSubnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "MainIGW"
  }
}

# Route Table pública
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

# Associação da tabela de rota pública à subnet pública
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# NAT Gateway (usando um IP elástico fictício)
resource "aws_eip" "nat_eip" {
  # vpc = true - depreciado em versões mais recentes do Terraform e do provedor AWS.
  tags = {
    Nam = "NATGatewayEIP"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "MainNATGateway"
  }
}


# Route table privada
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route = {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}

# Associação da tabela de rota privada à subnet privada
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# BUCKET S3 seguro

resource "aws_s3_bucket" "meu_bucket" {
  bucket = "meu-bucket-exemplo" # Aqui eu escolho um nome único para o bucket
  # acl = "private" # O padrão é "private", mas você pode alterar se necessário

  tags = {
    Name        = "meu Bucket Exemplo"
    Environment = "Dev"
  }
}