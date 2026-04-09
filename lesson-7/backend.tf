/*
terraform {
  backend "s3" {
    bucket         = "anhelov-test-lesson-7"
    key            = "lesson-7/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table"
  }
}
*/
