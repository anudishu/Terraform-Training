terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.16.0"
    }
  }
}

terraform {
  backend "gcs" {
    bucket  = "my-bucket-demo-2024-tf"
    prefix  = "terraform/terraform.tfstate"
  }
}



provider "google" {
  project     = var.project_name
  region      = var.region_name
  zone        = var.zone_name
  credentials = "key.json"
}

##------------- Storage Bucket ----------------------------

resource "google_storage_bucket" "bucket1" {
  name          = var.storage_name
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 3
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

##------------- Web Compute VM ----------------------------------
resource "google_compute_instance" "web1" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone_name

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }
  metadata_startup_script = <<-EOF
  sudo apt-get update && \
  sudo apt-get install apache2 -y && \
  echo "<!doctype html><html><body><h1>Hello World!</h1></body></html>" > /var/www/html/index.html
  EOF
}

