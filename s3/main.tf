provider aws {
    region =  "eu-west-3"
}


resource "aws_s3_bucket" "dev_bucket" {
  bucket = "faklamanu-tf-test-bucket"
  acl    = "private"

  versioning {
      enabled = true
  }

  tags = {
    Name        = "tf-bucket"
    Environment = "Dev"
  }
}



resource "aws_s3_bucket_object" "first_file" {
  bucket = aws_s3_bucket.dev_bucket.id
  key    = "first_file_tf_test_key"
  source = "test.txt"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("test.txt")

  force_destroy = true
}