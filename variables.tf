variable "cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "ami" {
  default = "ami-0b967c22fe917319b"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "mail_id" {
  default = "testing@gmail.com"
}
