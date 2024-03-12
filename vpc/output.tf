output "aws_vpc_id" {
  value = "${aws_vpc.mynginx_main.id}"
}

output "aws_internet_gw" {
  value = "${aws_internet_gateway.mynginx_gw.id}"
}

output "security_group_vpc" {
  value = "${aws_security_group.mynginx_sg.id}"
}
 
output "subnets" {
  value = "${aws_subnet.public_subnet.*.id}"
}
