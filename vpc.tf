# provider "aws"  {
#   version = "3.4.0"
# 	region = "ap-south-1"
# 	// profile = "shrey2"
# }
# // vpc creation
# resource "aws_vpc" "main" {
#   cidr_block       = "10.0.0.0/16"
#   instance_tenancy = "default"
#   enable_dns_hostnames = "true"

#   tags = {
#     Name = "vpc1"
#   }
# }
# // vpc subnets
# resource "aws_subnet" "subnet1" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.0.0/24"
#   availability_zone = "ap-south-1a"
#   depends_on=[aws_vpc.main]      
#   map_public_ip_on_launch = "true"

#   tags = {
#    Name ="publicsubnet"
#   }
# }
# resource "aws_subnet" "subnet12" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.1.0/24"
#   availability_zone = "ap-south-1b"
#   depends_on = [aws_vpc.main]

#   tags = {
#     Name = "Privatesubnet"
#   }
# }


# resource "aws_internet_gateway" "gw1" {
#   vpc_id = aws_vpc.main.id
#   depends_on = [aws_vpc.main]

#   tags = {
#     Name = "internet_gateway1"
#   }
# }

# resource "aws_eip" "lb" {
#   instance = aws_instance.MYSQL.id
#   vpc      = true
# }
# resource "aws_nat_gateway" "NATGateway" {
#   allocation_id = aws_eip.lb.id
#   subnet_id     = aws_subnet.subnet1.id
  
#   tags = {
#     Name = "Natgateway"
#   }
# }

# resource "aws_route_table" "NATRouteTable" {
#   vpc_id = aws_vpc.main.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.NATGateway.id
#   }
#  depends_on = [aws_vpc.main,aws_internet_gateway.gw1]

# }
# resource "aws_route_table" "route" {
#   vpc_id = aws_vpc.main.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.gw1.id
#   }
#  	tags = {
#   	Name  = "routetable"
#    }
# }

#   resource "aws_route_table_association" "a1" {
#   subnet_id      = aws_subnet.subnet1.id
#   route_table_id = aws_route_table.route.id

# }
#   resource "aws_route_table_association" "a2" {
#   subnet_id      = aws_subnet.subnet12.id
#   route_table_id = aws_route_table.route.id
# }
# // securiety group
#   resource "aws_security_group" "allow_tls" {
#   name        = "allow_tls"
#   description = "Allow TLS inbound traffic"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     description = "HTTP"
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = [aws_vpc.main.cidr_block]
#   }
# ingress {
#     description = "SSH"
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = [aws_vpc.main.cidr_block]
#   }
#   ingress {
#     description = "MYSQL"
#     from_port   = 3306
#      to_port     = 3306
#     protocol    = "tcp"
#     cidr_blocks = [aws_vpc.main.cidr_block]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   depends_on = [ aws_vpc.main ]

#   tags = {
#     Name = "allow_tls"
#   }
# }
#  resource "aws_instance" "WORDPRESS" {
#   ami           = "ami-052c08d70def0ac62"
#   instance_type = "t2.micro"
#   key_name = "key12"
#   vpc_security_group_ids = [aws_security_group.allow_tls.id]
#   subnet_id = aws_subnet.subnet1.id
   
#   connection {
#     type     = "ssh"
#     user     = "ec2-user"
#     private_key = file("C:/Users/gupta/Downloads/key12.pem")
#     host     = "aws_instance.web.public_ip"

#   }
# }
#   resource "aws_instance" "MYSQL" {
#   ami           = "ami-08706cb5f68222d09"
#   instance_type = "t2.micro"
#   key_name = "key12"
#   vpc_security_group_ids = [aws_security_group.allow_tls.id]
#    subnet_id = aws_subnet.subnet12.id
   
#   connection {
#     type     = "ssh"
#     user     = "ec2-user"
#     private_key = file("C:/Users/gupta/Downloads/key12.pem")
#     host     = "aws_instance.web.public_ip"

# }
#     }
# output "op1"{
# value = aws_vpc.main.id
# }




provider "aws"{
	region  = "ap-south-1"
  version = "3.4.0"
//	profile = "shrey2"
}

//VPC Creation
resource "aws_vpc" "VPC" {
  cidr_block       = "10.0.0.0/16"
  enable_dns_hostnames = "true"
  tags = {
    Name = "VPC"
  }
}

# Subnet Creation
//Public subnet for Wordpress
resource "aws_subnet" "publicSubnet" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = "true"
  depends_on = [aws_vpc.VPC]
  tags = {
    Name = "publicSubnet"
  }
}

//Private subnet for MySQL
resource "aws_subnet" "privateSubnet" {
  vpc_id     = aws_vpc.VPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1b"
  depends_on = [aws_vpc.VPC]
  tags = {
    Name = "privateSubnet"
  }
}

//Internet Gateway for VPC
resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.VPC.id
  depends_on = [aws_vpc.VPC]

  tags = {
    Name = "InternetGateway"
  }
}

//Elastic  IP for NATGateway
resource "aws_eip" "ElasticIP"{
  vpc = true
  tags = {
    Name = "ElasticIP"
  }
}

//NAT Gateway
resource "aws_nat_gateway" "NATGateway" {
  allocation_id = aws_eip.ElasticIP.id
  subnet_id     = aws_subnet.publicSubnet.id
  tags = {
    Name = "NATGateway"
  }
}

// Route Table for NAT
resource "aws_route_table" "NATRouteTable" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.NATGateway.id
  }
}


//Route Table for Public Subnet
resource "aws_route_table" "PublicRouteTable" {
  vpc_id = aws_vpc.VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.InternetGateway.id
  }
   depends_on = [aws_vpc.VPC, aws_internet_gateway.InternetGateway]

  tags = {
    Name = "PublicRouteTable"
  }
}


//Association with Public subnet
resource "aws_route_table_association" "PublicAssociation" {
  subnet_id      = aws_subnet.publicSubnet.id
  route_table_id = aws_route_table.PublicRouteTable.id


  depends_on = [
    aws_subnet.publicSubnet ,aws_route_table.PublicRouteTable
  ]
}

//Association with Private subnet
resource "aws_route_table_association" "privateAssociation" {
  subnet_id      = aws_subnet.privateSubnet.id
  route_table_id = aws_route_table.NATRouteTable.id
}

#Security Group

// For Wordpress
resource "aws_security_group" "wordpressSecurityGroup" {
  name        = "wordpressSecurityGroup"
  description = "allows ssh and http"
  vpc_id      = aws_vpc.VPC.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


    ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port = -1
    to_port = -1
    protocol  = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  depends_on = [ aws_vpc.VPC ]


  tags = {
    Name = "wordpressSecurityGroup"
  }
}

// For MySQL
resource "aws_security_group" "MySQLSecurityGroup" {
  name        = "MySQLSecurityGroup"
  description = "Allow only wordpress"
  vpc_id      = aws_vpc.VPC.id


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.publicSubnet.cidr_block]
  }

    ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.publicSubnet.cidr_block]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol  = "icmp"
    cidr_blocks = [aws_subnet.publicSubnet.cidr_block]
  }
  
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }  


  depends_on = [
    aws_vpc.VPC,
    aws_security_group.wordpressSecurityGroup,
  ]

  tags = {
    Name = "MySQLSecurityGroup"
  }
}

#EC2 Instances

//Wordpress Instance
resource "aws_instance" "WordPressInstance" {
  ami           = "ami-000cbce3e1b899ebd"
  instance_type = "t2.micro"
  key_name      = "key12"
  subnet_id     = aws_subnet.publicSubnet.id 
  vpc_security_group_ids = [aws_security_group.wordpressSecurityGroup.id]
  tags = {
    Name = "WordPressInstance"
  }
}

//MySQL Instance
resource "aws_instance" "MySQLInstance" {
  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  key_name      = "key12"
  subnet_id     = aws_subnet.privateSubnet.id
  vpc_security_group_ids = [aws_security_group.MySQLSecurityGroup.id]
  tags = {
    Name = "MySQLInstance"
  }
}


