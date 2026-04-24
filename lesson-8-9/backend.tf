/*
terraform {
  backend "s3" {
    bucket         = "anhelov-test-lesson-7"
    key            = "lesson-7/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "terraform-lock-table"
  }
}
*/