provider "aws" {
	region = "ap-south-1"
	profile = "shrey2"
}
// VPC CREATION
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = "true"

  tags = {
    Name = "vpc1"
  }
}
// SUBNET CREATION
resource "aws_subnet" "subnet1" {
  vpc_id  = "${aws_vpc.main.id}"
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
    depends_on=[aws_vpd.main.id]      
  map_public_ip_on_launch = "true" 
  tags = {
    Name = "publicsubnet"
  }
}

resource "aws_subnet" "subnet12" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
  depends_on=[aws_vpd.main.id]
  tags = {
    Name = "privatesubnet"
  }
}

resource "aws_internet_gateway" "gw1" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "internet_gateway1"
  }
}
// ROUTE TABLE
resource "aws_route_table" "route" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw1.id}"

  }

 	tags = {
  	Name  = "routetable"
   }
}
resource "aws_route_table_association" "a1" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.route.id
}
resource "aws_route_table_association" "a2" {
  subnet_id      = aws_subnet.subnet12.id
  route_table_id = aws_route_table.route.id
}

resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  ingress {
    description = "MYSQL"
    from_port   = 3306
     to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
resource "aws_instance" "WORDPRESS" {
  ami           = "ami-052c08d70def0ac62"
  instance_type = "t2.micro"
  key_name = "key12"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  subnet_id = "${aws_subnet.subnet1.id}"
   
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/gupta/Downloads/key12.pem")
    host     = "aws_instance.web.public_ip"

  }
}
  resource "aws_instance" "MYSQL" {
  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  key_name = "key12"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
   subnet_id = "${aws_subnet.subnet12.id}"
   
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("C:/Users/gupta/Downloads/key12.pem")
    host     = "aws_instance.web.public_ip"

}
    }
output "op1"{
value = aws_vpc.main.id
}