variable "pjt_name" {
  type        = string
  description = "Project name prefix for resources"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for EC2 instances"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "public_key" {
  type        = string
  description = "AWS EC2 Key Pair name"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where ASG is deployed"
}

variable "sg_id" {
  type        = string
  description = "Security Group ID for ASG EC2 instances"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for ASG"
}

variable "target_group_arn" {
  type        = string
  description = "ARN of the ALB target group to attach ASG"
}
