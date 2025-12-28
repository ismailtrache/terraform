variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_az" {
  type    = string
  default = "us-east-1a"
}

variable "aws_az_2" {
  type    = string
  default = "us-east-1b"
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

variable "public_subnet_cidr_2" {
  type    = string
  default = "10.0.2.0/24"
}

variable "ssh_ingress_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "s3_bucket_name" {
  type    = string
  default = "ismailtrache-uploads"
}

variable "app_s3_prefix" {
  type    = string
  default = "app/"
}

variable "domain_name" {
  type    = string
  default = "ismailtrache.me"
}

variable "www_domain_name" {
  type    = string
  default = "www.ismailtrache.me"
}

variable "flask_app_module" {
  type    = string
  default = "app:app"
}

variable "public_key" {
  type = string
}

variable "private_key_path" {
  type    = string
  default = ".secrets/ec2_key"
}

variable "root_volume_size" {
  type    = number
  default = 20
}
