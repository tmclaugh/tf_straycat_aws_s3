# tf_straycat__aws_s3
Creates S3 buckets to expected form.

_NOTE: This module will prepend the domain name and account name to every bucket.  This is to prevent naming collisions.  Particularly useful since each environment gets its own account._

## Variables
### Required
* ___s3_bucket_name:___ Name of bucket to create.  Pay attention to the fact that domain name and account name will be prepended to the bucket to help prevent name collisions.

* ___aws_account:___ Name of AWS account.  Used to find remote state information and is prepended to bucket names.

* ___aws_region:___ AWS region.  Used to find remote state.

### Optional
* ___s3_logs_bucket:___ Bucket for storing AWS access logs.

* ___versioning:___ Enable objct versioning.

* ___domain:___ Environment's domain name; used to help finding remote state bucket and added to bucket names.

