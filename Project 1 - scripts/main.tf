###### Unfinished- trying to use terraform to create 2-tier app deployment
# Managed to run app vm not db yet (with changing db ip)

# Provider = aws
provider "aws" {
  region = "eu-west-1"
}

# Creating a vpc
resource "aws_vpc" "zainab-vpc" {
  cidr_block = "10.0.0.0/16"
}

# Creating a public subnet
resource "aws_subnet" "zainab-public-subnet" {
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true
  vpc_id = aws_vpc.zainab-vpc.id
}

# Creating an internet gateway for the public subnet
resource "aws_internet_gateway" "zainab-igw" {
  vpc_id = aws_vpc.zainab-vpc.id

  tags = {
    Name = "zainab-igw"
  }
}

# Creating a route table
resource "aws_route_table" "zainab-rt-public" {
  vpc_id = aws_vpc.zainab-vpc.id
}

# Defining a route to anywhere associating it with the route table.
resource "aws_route" "zainab-rt-route" {
  route_table_id = aws_route_table.zainab-rt-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.zainab-igw.id
}

# Associating the route table to public subnet 
resource "aws_route_table_association" "zainab-rt-assoc" {
  subnet_id = aws_subnet.zainab-public-subnet.id
  route_table_id = aws_route_table.zainab-rt-public.id
}

##########################################################

# Creating a private subnet
#resource "aws_subnet" "zainab-private-subnet" {
  #cidr_block = "10.0.3.0/24"
  #availability_zone = "eu-west-1a"
  #vpc_id = aws_vpc.zainab-vpc.id
#}

#resource "aws_eip" "myeip" {
 # domain = "vpc"
#}

# Creating a nat gateway and associating it with the private subnet
#resource "aws_nat_gateway" "zainab-nat-gateway" {
 # subnet_id = aws_subnet.zainab-private-subnet.id
 # allocation_id = aws_eip.myeip.id
#}

# Creating a route table
#resource "aws_route_table" "zainab-rt-private" {
  #vpc_id = aws_vpc.zainab-vpc.id
#}

# Defining a route to anywhere associating it with the route table and nat gateway
#resource "aws_route" "zainab-rt-route-priv" {
 # route_table_id = aws_route_table.zainab-rt-private.id
 # destination_cidr_block = "0.0.0.0/0"
 # gateway_id = aws_nat_gateway.zainab-nat-gateway.id
#}

# Associating the route table to private subnet
#resource "aws_route_table_association" "zainab-rt-assoc-priv" {
 # subnet_id = aws_subnet.zainab-private-subnet.id
 # route_table_id = aws_route_table.zainab-rt-private.id
#}
######################################################

resource "aws_security_group" "zainab-app-sg" {
    name        = "zainab-app-sg"
    description = "security group"
    vpc_id = aws_vpc.zainab-vpc.id

    tags = {
        Name = "zainab-app-sg"
    }
}

resource "aws_vpc_security_group_ingress_rule" "allow-ssh" {
  security_group_id = aws_security_group.zainab-app-sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  cidr_ipv4  = "88.97.161.118/32"
}

resource "aws_vpc_security_group_ingress_rule" "allow-http" {
  security_group_id = aws_security_group.zainab-app-sg.id
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
  cidr_ipv4 =   "0.0.0.0/0"


}

resource "aws_vpc_security_group_ingress_rule" "allow-3000" {
  security_group_id = aws_security_group.zainab-app-sg.id
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
  cidr_ipv4 =   "0.0.0.0/0"

}

resource "aws_vpc_security_group_ingress_rule" "allow-27017" {
  security_group_id = aws_security_group.zainab-app-sg.id
  from_port         = 27017
  ip_protocol       = "tcp"
  to_port           = 27017
  cidr_ipv4 =   "0.0.0.0/0"

}

# Creating a key pair for ec2
resource "aws_key_pair" "zainab-key-tf" {
  key_name   = "zainab-tf-my-existing-keypair"
  public_key = file("~/.ssh/zainab-test-ssh-2.pub")  # Replace with your actual public key path
}

###########################################
# DB VM with image created previously with script (using custom AMI I created).
#resource "aws_instance" "db_instance" {

  # what AMI ID
  #ami = "ami-0e4ace8012c7d6c4a"

  # which type of instance
  #instance_type = "t3.micro"

  # public Ip
  #associate_public_ip_address = true

  # security group
 # vpc_security_group_ids = [aws_security_group.zainab-app-sg.id]
  
  # key pair
 # key_name = aws_key_pair.zainab-key-tf.id
#
  # Put it into the public subnet
  #subnet_id = aws_subnet.zainab-public-subnet.id

  # name the isntance
  #tags = {
  #  Name = "tech501-zainab-terraform-db-script-image"
 # }

#}

#output "database-private-IP" {
#  value = aws_instance.db_instance.private_ip
#}

resource "aws_instance" "app_instance" {

  # what AMI ID
  ami = "ami-011f5bcfc7ee98ac9"

  # which type of instance
  instance_type = "t3.micro"

  # public Ip
  associate_public_ip_address = true

  # security group
  vpc_security_group_ids = [aws_security_group.zainab-app-sg.id]
  
  # key pair
  key_name = aws_key_pair.zainab-key-tf.id

  # Put it into the public subnet
  subnet_id = aws_subnet.zainab-public-subnet.id

  # Making sure it's created after the db
 # depends_on = [ aws_instance.db_instance ]

  # name the isntance
  tags = {
    Name = "tech501-zainab-terraform-app-script-image"
  }
  
  user_data = file("${path.module}/run-app-only.sh")
#<<EOF
#!/bin/bash

# Fetch DB Private IP
#export DB_IP=${aws_instance.db_instance.private_ip}
#echo "DB_IP=$DB_IP" >> /etc/environment

#EOF
}


