terraform {
    backend "s3" {
        bucket          = "faklamanu-tf-test-bucket"
        key             = "remote_state/terraform.tfstate" 
        region          = "eu-west-3"
        dynamodb_table   = "statelocking"    
    }
}