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


#---------- Create VPC---------------
resource "google_compute_network" "vpc_network1" {
  name = "vpc-network"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet1" {
  name          = "subnet1"
  ip_cidr_range = "10.255.182.0/24"
  network       = google_compute_network.vpc_network1.name
  region        = "us-central1"
  #private_ip_google_access = true
  
  # log_config {
  #   aggregation_interval = "INTERVAL_10_MIN"
  #   flow_sampling        = 0.5
  #   metadata             = "INCLUDE_ALL_METADATA"
  # }

}

# resource "google_compute_subnetwork" "subnet2" {
#   name          = "subnet2"
#   ip_cidr_range = "10.255.184.0/24"
#   network       = google_compute_network.vpc_network1.name
#   region        = "us-east1"

# }


#-------- Compute VM------------------

resource "google_compute_instance" "web1" {
  count        = 2
  name         = var.instance_name[count.index]
  machine_type = "g1-small"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network1.name
    subnetwork = google_compute_subnetwork.subnet1.name

  }

  metadata_startup_script = <<-EOF
  sudo apt-get update && \
  sudo apt-get install apache2 -y && \
  echo "<!doctype html><html><body><h1>Hello World!</h1></body></html>" > /var/www/html/index.html
  EOF
}





