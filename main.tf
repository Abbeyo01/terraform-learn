provider "aws" {
  region     = "us-east-1"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
/*variable my_ip {}*/
variable instance_type {}
variable public_key_location {}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = { 
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "myapp-subnet-1" {
  vpc_id            = aws_vpc.myapp-vpc.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = { 
    Name = "${var.env_prefix}-subnet-1"
  }
}

/*new route table
resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = { 
    Name = "${var.env_prefix}-rtb"
  }
}*/

resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.myapp-vpc.id
  tags = { 
    Name = "${var.env_prefix}-igw"
  }
}

resource "aws_default_route_table" "main-rtb" {
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = { 
    Name = "${var.env_prefix}-main-rtb"
  }
}

# Dynamically fetch the public IP
data "http" "my_ip" {
  url = "https://api.ipify.org?format=text"
}

output "my_ip" {
  value = data.http.my_ip.response_body
  description = "The dynamically fetched public IP address of the system running Terraform."
}


/*resource "aws_security_group" "myapp-sg" 
or use below*/
# Default security group allowing SSH access from your IP
resource "aws_default_security_group" "default-sg" {
  vpc_id = aws_vpc.myapp-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${data.http.my_ip.response_body}/32"] # Dynamically fetched IP
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = [ ]
  }

  tags = { 
      Name = "${var.env_prefix}-default-sg"
  }

}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}
# Elastic IP to assign a static public IP to the EC2 instance
resource "aws_eip" "myapp_eip" {
  instance = aws_instance.myapp-server.id

  tags = {
    Name = "${var.env_prefix}-elastic-ip"
  }
}

# Output the Elastic IP assigned to the instance
output "ec2_public_ip" {
  value = aws_eip.myapp_eip.public_ip
}

/*resource "aws_eip" "myapp_eip" {
  instance = aws_instance.myapp-server.id
}

output "ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip
}*/

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = "${file(var.public_key_location)}"
}

# EC2 Instance Configuration
resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.myapp-subnet-1.id
  vpc_security_group_ids = [aws_default_security_group.default-sg.id]
  availability_zone = var.avail_zone

  # associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  # Use the entry-script.sh file for user_data
  user_data = file("entry-script.sh")

  tags = {
      Name = "${var.env_prefix}-server"
  }
}


/*new association route tables
resource "aws_route_table_association" "a-rtb-subnet" {
  subnet_id = aws_subnet.myapp-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
}*/