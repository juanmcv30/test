variable "project" {
  default      =  "eighth-etching-403617"
  description  =  " "
}
variable "region" {
  default      =  "us-central1"
  description  =  " "
}
variable "zone" {
  default      =  "us-central1-a"
  description  =  " "
}
variable "instance_name" {
  default      =  "windows-vm"
  description  =  " "
}
variable "admin_username" {
  default      =  "admin"
  description  =  " "
}
variable "password_length" {
  type    = number
  default = 16
}
variable "network_name" {
  default      =  "main"
  description  =   " "
}
variable "subnet_name" {
  default      =  "public-subnet"
  description  =  " "
}
