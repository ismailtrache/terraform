variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_az" {
  type    = string
  default = "us-east-1a"
}

variable "name" {
  type    = string
  default = "flask-ec2"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "ssh_ingress_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "private_key_path" {
  type    = string
  default = "ec2_key.pem"
}

variable "root_volume_size" {
  type    = number
  default = 20
}
