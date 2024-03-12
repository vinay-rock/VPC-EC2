provider "aws" {
  region = "us-east-1"
}

module "my_vpc" {
  source             = "./vpc"
  region             = "us-east-1"
  vpc_cidr           = "10.0.0.0/16"
  public_cidrs       = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_cidrs      = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  vpc_tag            = "my_vpc"
  igw_tag            = "my_igw"
  public_subnet_tag  = "my_public_subnet"
  private_subnet_tag = "my_private_subnet"
}

module "my_ec2" {
  source            = "./ec2"
  region            = "us-east-1"
  my_key_name       = "mytfkey"
  instance_type     = "t2.micro"
  security_group    = "${module.my_vpc.security_group_vpc}"
  subnet            = "${module.my_vpc.subnets}"
  iam_profile       = "my-tf-test"
  ami               = "ami-02d7fd1c2af6eead0"
  ec2_tag           = "my-test"
  ec2_count         = "1"
  }

