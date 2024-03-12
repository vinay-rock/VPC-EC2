# AWS Region
variable "region" {}

variable "vpc_cidr" {}
variable "public_cidrs" {
  type    = list(string)
}

variable "private_cidrs" {
  type    = list(string)
}

variable "vpc_tag" {}
variable "igw_tag" {}

variable "public_subnet_tag" {}
variable "private_subnet_tag" {}