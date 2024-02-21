terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.16.0"
    }
  }
}



provider "google" {
  project     = "mindful-marking-388908"
  region      = "us-central1"
  zone        = "us-central1-a"
  credentials = file("key.json")
}


#---------- fetching VPC and Subnets---------------
data "google_compute_network" "my-network1" {
  name = "vpc-1"
}

data "google_compute_subnetwork" "my-subnetwork" {
  name   = "subnet2-us-central"
  region = "us-central1"
}

#-------- Compute VM--------------------------

resource "google_compute_instance" "web1" {

  name         = "web"
  machine_type = "g1-small"
  zone         = "us-central1-c"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = data.google_compute_network.my-network1.name
    subnetwork = data.google_compute_subnetwork.my-subnetwork.name

  }

  metadata_startup_script = <<-EOF
  sudo apt-get update && \
  sudo apt-get install apache2 -y && \
  echo "<!doctype html><html><body><h1>Hello World!</h1></body></html>" > /var/www/html/index.html
  EOF
}





