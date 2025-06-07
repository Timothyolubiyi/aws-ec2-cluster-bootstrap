variable "region" {
  default = "eu-north-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "ami_id" {
  default = "ami-0c1ac8a41498c1a9c" # Amazon Linux 2 AMI (for eu-north-1)
}

variable "instance_type" {
  default = "t3.micro"
}
