output "aws_ami_id" {
  #value = data.aws_ami.latest-amazon-linux-image.id
  #value = module.myapp-server.aws.ami.latest-amazon-linux-image.id
  value = module.myapp-server.aws_ami_id.id
}



#output "my_ip" {
 # value = data.http.my_ip.response_body
 # description = "The dynamically fetched public IP address of the system running Terraform."
#}
output "my_ip" {
  value = module.myapp-server.my_ip
  description = "The dynamically fetched public IP address of the system running Terraform."
}
# Output the Elastic IP assigned to the instance
output "ec2_public_ip" {
  value = module.myapp-server.instance-ec2_public_ip.public_ip
  #value = module.myapp-server.ec2_public_ip
}


/*resource "aws_eip" "myapp_eip" {
  instance = aws_instance.myapp-server.id
}

output "ec2_public_ip" {
  value = aws_instance.myapp-server.public_ip
}*/
