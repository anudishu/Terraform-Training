/*
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.16.0"
    }
  }
}
*/
provider "google" {
  project = "mindful-marking-388908"
  region  = "us-central1"
  zone    = "us-central1-c"
  credentials = file("key.json")
}


terraform {
  cloud {
    organization = "my-demo-org-dishu"

    workspaces {
      name = "my-clidriven-demo"
    }
  }
}

resource "google_storage_bucket" "auto-expire" {
  name          = "contechus-2024-bucket"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 2
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      age = 1
    }
    action {
      type = "AbortIncompleteMultipartUpload"
    }
  }
}
