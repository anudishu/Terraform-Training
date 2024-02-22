# to setup a web-server

resource "random_id" "rnd" {
  byte_length = 4
}

resource "google_compute_instance" "default" {
  name         = "dns-compute-instance"
  machine_type = "g1-small"
  zone         = "us-central1-b"

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

# to allow http traffic
resource "google_compute_firewall" "default" {
  name    = "allow-http-traffic"
  network = "default"
  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
  source_ranges = ["0.0.0.0/0"]
}

# # to create a DNS zone
# resource "google_dns_managed_zone" "default" {
#   name          = "lyfedge-com"
#   dns_name      = "lyfedge,com."
#   description   = "lyfedge Public DNS zone"
#   force_destroy = "true"
# }

data "google_dns_managed_zone" "env_dns_zone" {
  name = "lyfedge-com"
  
}

# to register web-server's ip address in DNS
resource "google_dns_record_set" "default" {
  name         = data.google_dns_managed_zone.env_dns_zone.dns_name
  managed_zone = data.google_dns_managed_zone.env_dns_zone.name
  type         = "A"
  ttl          = 300
  rrdatas = [
    google_compute_instance.default.network_interface[0].access_config[0].nat_ip
  ]
}