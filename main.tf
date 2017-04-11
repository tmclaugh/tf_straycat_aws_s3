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

# FIXME: Need to figure out how to pass in the name of the S3 bucket that has
# yet to be resolved due to our name mangling.
#variable "s3_buckety_policy" {
#  description = "Optional bucket policy"
#  default = ""
#}

variable "versioning" {
  default = "false"
}

variable "aws_s3_prefix" {
  type = "string"
  description = "Used to help finding remote state bucket"
  default = "straycat-dhs-org"
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
    bucket  = "${var.aws_s3_prefix}-${var.aws_account}-terraform"
    key     = "root.tfstate"
    region  = "${var.aws_region}"
  }
}


# Resources
resource "aws_s3_bucket" "bucket" {
  # This is to keep things consistrent and prevent conflicts across
  # environments.
  bucket = "${var.aws_s3_prefix}-${var.aws_account}-${var.s3_bucket_name}"
  acl    = "${var.s3_bucket_acl}"

  versioning = {
    enabled = "${var.versioning}"
  }

  logging = {
    target_bucket = "${var.s3_logs_bucket == "default" ? data.terraform_remote_state.root.aws_s3_bucket_infra_logs_bucket_id : var.s3_logs_bucket}"
    target_prefix = "s3/${var.aws_s3_prefix}-${var.aws_account}-${var.s3_bucket_name}/"
  }

  force_destroy = true

  tags = {
    terraform = "true"
  }
}

# FIXME: Need to figure out how to pass in the name of the S3 bucket that has
# yet to be resolved due to our name mangling.
#resource "aws_s3_buckey_policy" "bucket" {
#  count  = "${length(var.s3_bucket_policy) > 1 ? 1 : 0 }"
#  bucket = "${aws_s3_bucket.bucket.id}"
#  policy = "${var.s3_bucket_policy}"
#}

# Outputs
output "bucket_id" {
  value = "${aws_s3_bucket.bucket.id}"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.bucket.arn}"
}

