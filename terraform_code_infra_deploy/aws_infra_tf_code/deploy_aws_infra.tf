resource "aws_vpc" "saurav_aws_vpc" {
cidr_block = "10.0.0.0/16"
enable_dns_support = true
enable_dns_hostnames = true
tags = {
Name = "saurav_aws_vpc"
}

}

resource "aws_subnet" "saurav_aws_public_subnet_1" {
vpc_id = aws_vpc.saurav_aws_vpc.id
cidr_block = "10.0.1.0/24"
availability_zone = "us-east-1a"
map_public_ip_on_launch = true
tags = {
Name = "saurav_aws_public_subnet_1"
}
}

resource "aws_subnet" "saurav_aws_public_subnet_2" {
vpc_id = aws_vpc.saurav_aws_vpc.id
cidr_block = "10.0.2.0/24"
availability_zone = "us-east-1b"
map_public_ip_on_launch = true
tags = {
Name = "saurav_aws_public_subnet_2"
}
}

resource "aws_subnet" "saurav_aws_private_subnet_1" {
vpc_id = aws_vpc.saurav_aws_vpc.id
cidr_block = "10.0.3.0/24"
availability_zone = "us-east-1a"
tags = {
Name = "saurav_aws_private_subnet_1"
}
}

resource "aws_subnet" "saurav_aws_private_subnet_2" {
vpc_id = aws_vpc.saurav_aws_vpc.id
cidr_block = "10.0.4.0/24"
availability_zone = "us-east-1b"
tags = {
Name = "saurav_aws_private_subnet_2"
}
}

resource "aws_internet_gateway" "saurav_aws_igw" {
vpc_id = aws_vpc.saurav_aws_vpc.id
tags = {
Name = "saurav_aws_igw"
}
}

resource "aws_eip" "saurav_aws_nat_eip" {
instance = null
tags = {
Name = "saurav_aws_nat_eip"
}
}


resource "aws_nat_gateway" "saurav_aws_nat_gateway" {
allocation_id = aws_eip.saurav_aws_nat_eip.id
subnet_id = aws_subnet.saurav_aws_public_subnet_1.id
tags = {
Name = "saurav_aws_nat_gateway"
}
}


resource "aws_route_table" "saurav_aws_public_route_table" {
vpc_id = aws_vpc.saurav_aws_vpc.id

route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.saurav_aws_igw.id
}
tags = {
Name = "saurav_aws_public_route_table"
}
}

resource "aws_route_table" "saurav_aws_private_route_table" {
vpc_id = aws_vpc.saurav_aws_vpc.id
tags = {
Name = "saurav_aws_private_route_table"
}
}


resource "aws_route" "saurav_aws_private_route_nat" {
route_table_id = aws_route_table.saurav_aws_private_route_table.id
destination_cidr_block = "0.0.0.0/0"
nat_gateway_id = aws_nat_gateway.saurav_aws_nat_gateway.id
}

resource "aws_route_table_association" "saurav_aws_public_subnet_association_1" {
subnet_id = aws_subnet.saurav_aws_public_subnet_1.id
route_table_id = aws_route_table.saurav_aws_public_route_table.id
}

resource "aws_route_table_association" "saurav_aws_public_subnet_association_2" {
subnet_id = aws_subnet.saurav_aws_public_subnet_2.id
route_table_id = aws_route_table.saurav_aws_public_route_table.id
}

resource "aws_route_table_association" "saurav_aws_private_subnet_association_1" {
subnet_id = aws_subnet.saurav_aws_private_subnet_1.id
route_table_id = aws_route_table.saurav_aws_private_route_table.id
}

resource "aws_route_table_association" "saurav_aws_private_subnet_association_2" {
subnet_id = aws_subnet.saurav_aws_private_subnet_2.id
route_table_id = aws_route_table.saurav_aws_private_route_table.id
}

resource "aws_security_group" "saurav_aws_sg" {
name_prefix = "saurav_aws_sg-"
description = "Allow ssh and https"
vpc_id = aws_vpc.saurav_aws_vpc.id

// Inbound rule for port 80
ingress {
from_port = 80
to_port = 80
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

// Inbound rule for port 22
ingress {
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

// Egress rule for all ports
egress {
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}

tags = {
Name = "saurav_aws_sg"
}
}

# Create key pair resource
resource "aws_key_pair" "aws_upgrad_labkey" {
  key_name   = "aws_upgrad_labkey"
  public_key = file("/Users/sauravsuman/terraform/capstone/pubkey.pub")
  tags = {
    Name = "aws_upgrad_labkey"
  }
}

# EC2 Instance for App Machine
resource "aws_instance" "app_machine" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.saurav_aws_public_subnet_1.id
  key_name      = aws_key_pair.aws_upgrad_labkey.key_name
  vpc_security_group_ids = [aws_security_group.saurav_aws_sg.id]

  tags = {
    Name = "App Machine"
  }
}

# EC2 Instance for Tools Machine
resource "aws_instance" "tools_machine" {
  ami           = "ami-0e86e20dae9224db8"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.saurav_aws_public_subnet_2.id
  key_name      = aws_key_pair.aws_upgrad_labkey.key_name
  vpc_security_group_ids = [aws_security_group.saurav_aws_sg.id]

  root_block_device {
   volume_size = 50  # Size in GiB
   volume_type = "gp3"  # General Purpose SSD, adjust as needed
   delete_on_termination = true  # Optional: Automatically delete the volume when the instance is terminated
  }

  tags = {
    Name = "Tools Machine"
  }
}
