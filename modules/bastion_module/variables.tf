variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "pjt_name" {
  type = string
}

variable "region" {
  type = string
}

variable "public_key" {
  type        = string
  description = "AWS EC2 Key Pair name (not the public key string)"
}
