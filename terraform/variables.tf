variable "region" {
  type = string
  default = "us-east-1"
}

variable "ami" {
  type = string
  default = "ami-04b4f1a9cf54c11d0"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "ssh_key_name" {
  type = string
  default = "nginx_server_ssh_key"
}

variable "security_groups" {
  type = string
  default = "nginx_sg"
}

variable "domain" {
  type = string
  default = "kenjiasb.com"
}

variable "nginx_server_url" {
  type = string
  default = "nginx.kenjiasb.com"
}