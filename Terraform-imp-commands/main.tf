
provider "google" {
  project     = "mindful-marking-388908"
  region      = "us-central1"
  zone        = "us-central1-a"
  credentials = file("key.json")
}






resource "google_compute_instance" "web2" {
  name         = "web2"
  machine_type = "g1-small"
  zone         = "us-central1-a"

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
   lifecycle {
    prevent_destroy = true # Default is false
  }
  metadata_startup_script = <<-EOF
  sudo apt-get update && \
  sudo apt-get install apache2 -y && \
  echo "<!doctype html><html><body><h1>Hello World!</h1></body></html>" > /var/www/html/index.html
  EOF
}



resource "google_compute_instance" "web3" {
  name         = "web3"
  machine_type = "e2-small"
  zone         = "us-central1-a"

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
    lifecycle {
    prevent_destroy = true # Default is false
  }

  metadata_startup_script = <<-EOF
  sudo apt-get update && \
  sudo apt-get install apache2 -y && \
  echo "<!doctype html><html><body><h1>Hello World!</h1></body></html>" > /var/www/html/index.html
  EOF
}