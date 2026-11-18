variable "api_port" {
  type    = number
  default = 3000
}

variable "api_image_id" {
  type = string
}

variable "db_name" {
  type    = string
  default = "catalogue"
}

variable "db_user" {
  type    = string
  default = "catalogue"
}

variable "db_password" {
  type      = string
  sensitive = true
}
