
# Create VPC
resource "aws_vpc" "terra_vpc" {
  cidr_block = "10.0.0.0/16" # Change to your preferred CIDR block
  tags = {
    Name = "terra_vpc"
  }
}

# Create public subnet
resource "aws_subnet" "example_public_subnet" {
  vpc_id = aws_vpc.example_vpc.id
  cidr_block = "10.0.1.0/24" # Change to your preferred CIDR block
  availability_zone = "us-east-1a" # Change to your preferred availability zone
  tags = {
    Name = "example-public-subnet"
  }
}

# Create private subnet
resource "aws_subnet" "example_private_subnet" {
  vpc_id = aws_vpc.example_vpc.id
  cidr_block = "10.0.2.0/24" # Change to your preferred CIDR block
  availability_zone = "us-east-1b" # Change to your preferred availability zone
  tags = {
    Name = "example-private-subnet"
  }
}

# Create internet gateway
resource "aws_internet_gateway" "example_igw" {
  vpc_id = aws_vpc.example_vpc.id
  tags = {
    Name = "example-igw"
  }
}

# Attach internet gateway to VPC
resource "aws_vpc_attachment" "example_vpc_attachment" {
  vpc_id = aws_vpc.example_vpc.id
  internet_gateway_id = aws_internet_gateway.example_igw.id
}


# creating nat gateway
resource "aws_eip" "terra_nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.terra_nat_gateway.id
  subnet_id     = aws_subnet.public.id
}

# Create route table for public subnet
resource "aws_route_table" "example_public_route_table" {
  vpc_id = aws_vpc.example_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }
  tags = {
    Name = "example-public-route-table"
  }
}

# Associate public subnet with public route table
resource "aws_route_table_association" "example_public_subnet_association" {
  subnet_id = aws_subnet.example_public_subnet.id
  route_table_id = aws_route_table.example_public_route_table.id
}

# Create security group for instances in private subnet
resource "aws_security_group" "example_private_sg" {
  name_prefix = "example-private-sg"
  vpc_id = aws_vpc.example_vpc.id
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"] # Allow traffic from public subnet
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create instance in private subnet
resource "aws_instance" "example_private_instance" {
  ami = "ami-0c94855ba95c71c99" # Change to your preferred AMI
  instance_type = "t2.micro" # Change to your preferred instance type
  subnet_id = aws_subnet.example_private_subnet.id
  vpc_security_group_ids = [aws_security_group.example_private_sg.id]
  tags = {
    Name = "example-private-instance"
  }
}
