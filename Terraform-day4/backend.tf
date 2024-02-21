terraform {
  backend "gcs" {
    bucket = "my-bucket-demo-2024-tf"
    prefix = "terraform/terraform.tfstate"
  }
}
