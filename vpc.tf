# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Project-Cluster-Servers-VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-servers-IGW"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# AWS Public Subnet
resource "aws_subnet" "public" {
  count                   = 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = "${var.region}a"
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}
# Apache server script
data "template_file" "apache" {
  template = <<EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
EOF
}





# (NAT Gateway and Elastic IP resources here...)

# Associate Public Route Table with Public Subnet
resource "aws_route_table_association" "public_assoc" {
  count          = 3
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}


# IAM Role
# (IAM Role and Policy Attachment resources here...)

# EC2 Instance in the Public Subnet
resource "aws_instance" "server1" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = "Timtee"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data              = file("nginx-script.sh")
  tags = {
    Name = "server1-nginx"
  }
}

resource "aws_instance" "server2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = "Timtee"
  subnet_id              = aws_subnet.public[1].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data              = data.template_file.apache.rendered
  tags = {
    Name = "server2-apache"
  }
}

resource "aws_instance" "server3" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = "Timtee"
  subnet_id              = aws_subnet.public[2].id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  user_data              = file("jenkins-script.sh")
  tags = {
    Name = "server3-jenkins"
  }
}
