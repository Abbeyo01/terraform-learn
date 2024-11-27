#output "aws_ami_id" {
  #value = data.aws_ami.latest-amazon-linux-image.id
  #value = module.aws_ami.latest-amazon-linux-image.id

#}

output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image
}


output "my_ip" {
  value = data.http.my_ip.response_body
  description = "The dynamically fetched public IP address of the system running Terraform."
}

# Output the Elastic IP assigned to the instance old one
#output "ec2_public_ip" {
output "instance-ec2_public_ip" {
    value = aws_eip.myapp_eip
    #value = aws_eip.myapp_eip.public_ip  # old
}

/*resource "aws_eip" "myapp_eip" {
  instance = aws_instance.myapp-server.id
}

output "ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip
}*/