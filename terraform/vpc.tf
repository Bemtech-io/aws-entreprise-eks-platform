data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_vpc" "enterprise_eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "enterprise-eks-vpc"
  }
}

# Subnets

resource "aws_subnet" "public" {
  count                   = 1
  vpc_id                  = aws_vpc.enterprise_eks_vpc.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "enterprise-public-${data.aws_availability_zones.available.names[count.index]}"
    Tier = "public"
  }
}


resource "aws_subnet" "private" {
  count      = 1
  vpc_id     = aws_vpc.enterprise_eks_vpc.id
  cidr_block = "10.0.${count.index + 10}.0/24"

  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "enterprise-private-${data.aws_availability_zones.available.names[count.index]}"
    Tier = "private"
  }
}

resource "aws_subnet" "isolated" {
  count             = 1
  vpc_id            = aws_vpc.enterprise_eks_vpc.id
  cidr_block        = "10.0.${count.index + 20}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "enterprise-isolated-${data.aws_availability_zones.available.names[count.index]}"
    Tier = "isolated"
  }
}

# Internet gateway

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.enterprise_eks_vpc.id
  tags = {
    Name = "enterprise-internet-gateway"
  }
}

# Nat gateway configuration

resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = {
    Name = "enterprise-eks-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id
  depends_on    = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "enterprise-nat-gateway"
  }
}

#Route tables

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.enterprise_eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table" "isolate_route_table" {
  vpc_id = aws_vpc.enterprise_eks_vpc.id

  tags = {
    Name = "isolated-route-table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.enterprise_eks_vpc.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }


  tags = {
    Name = "private-route-table"
  }
}


# Route table association

resource "aws_route_table_association" "public_association" {
  count          = 1
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_association" {
  count          = 1
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "isolated_association" {
  count          = 1
  subnet_id      = aws_subnet.isolated[count.index].id
  route_table_id = aws_route_table.isolate_route_table.id
}



