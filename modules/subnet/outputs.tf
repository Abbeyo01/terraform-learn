/*output "subnet" {
    #value = aws_subnet.myapp-subnet-1
    value = aws_subnet.myapp-subnet.id
}**/

output "subnet" {
  value = aws_subnet.myapp-subnet.id
}
