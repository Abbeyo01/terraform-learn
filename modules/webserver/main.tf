resource "aws_default_security_group" "default-sg" {
  vpc_id = var.vpc_id.id

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
    values = [var.image_name]
    #values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}


# Dynamically fetch the public IP
data "http" "my_ip" {
  url = "https://api.ipify.org?format=text"
}

# Elastic IP to assign a static public IP to the EC2 instance
resource "aws_eip" "myapp_eip" {
  instance = aws_instance.myapp-server.id

  tags = {
    Name = "${var.env_prefix}-eip"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = "${file(var.public_key_location)}"
}

# EC2 Instance Configuration
resource "aws_instance" "myapp-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  #subnet_id = module.myapp-subnet.subnet_id
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

