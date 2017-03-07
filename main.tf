/*
* Creates S3 buckets for an environment.
*
* TODO:
* - Better access management.
*/

# Variables
variable "s3_bucket_name" {}

variable "s3_logs_bucket" {
  type = "string"
  description = "Bucket for storing AWS access logs"
  default = "default"
}

variable "s3_bucket_acl" {
  type = "string"
  description = "S3 bucket ACL"
  default = "private"
}

variable "versioning" {
  default = "false"
}

variable "domain" {
  type = "string"
  description = "Environment's domain name; used to help finding remote state bucket"
  default = "straycat.dhs.org"
}

variable "aws_account" {
  type = "string"
  description = "Account name"
}

variable "aws_region" {
  type = "string"
  description = "AWS region"
}


# Data
data "terraform_remote_state" "root" {
  backend = "s3"
  config = {
    bucket  = "${var.domain}-${var.aws_account}-terraform"
    key     = "root.tfstate"
    region  = "${var.aws_region}"
  }
}


# Resources
resource "aws_s3_bucket" "bucket" {
  # This is to keep things consistrent and prevent conflicts across
  # environments.
  bucket = "${var.domain}-${var.aws_account}-${var.s3_bucket_name}"
  acl    = "${var.s3_bucket_acl}"

  versioning = {
    enabled = "${var.versioning}"
  }

  logging = {
    target_bucket = "${var.s3_logs_bucket == "default" ? data.terraform_remote_state.root.aws_s3_bucket_infra_logs_bucket_id : var.s3_logs_bucket}"
    target_prefix = "s3/${var.domain}-${var.aws_account}-${var.s3_bucket_name}/"
  }

  tags = {
    terraform = "true"
  }
}


# Outputs
output "bucket_id" {
  value = "${aws_s3_bucket.bucket.id}"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.bucket.arn}"
}

