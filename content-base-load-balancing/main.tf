# https://cloud.google.com/compute/docs/load-balancing/http/content-based-example


terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.16.0"
    }
  }
}

provider "google" {
  region      = var.region
  project     = var.project_name
  #credentials = file(var.credentials_file_path)
  zone        = var.region_zone
}

#---------------Create Compute Instance Web Server----------------------
resource "google_compute_instance" "www" {
  name         = "tf-www-compute"
  machine_type = "f1-micro"
  tags         = ["http-tag"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-11"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = file("scripts/install-www.sh")

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}

#---------------Create Compute Instance Video Server----------------------
resource "google_compute_instance" "www-video" {
  name         = "tf-www-video-compute"
  machine_type = "f1-micro"
  tags         = ["http-tag"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-11"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = file("scripts/install-video.sh")

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}

#---------------Reserver Global Eternal IP Address ----------------------
resource "google_compute_global_address" "external-address" {
  name = "tf-external-address"
}

#---------------Instance Group WWW -------------------------------------
resource "google_compute_instance_group" "www-resources" {
  name      = "tf-www-resources"
  instances = [google_compute_instance.www.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}

#-----------------Instance Group Video------------------------------------
resource "google_compute_instance_group" "video-resources" {
  name      = "tf-video-resources"
  instances = [google_compute_instance.www-video.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}


#---------------Create Health check for backends---------------------
resource "google_compute_health_check" "health-check" {
  name = "tf-health-check"

  http_health_check {
    request_path = "/"  # Assuming your service responds to root path
    
    port = 80
  }
}

#---------------Create backend service for WWW-Service----------------------
resource "google_compute_backend_service" "www-service" {
  name     = "tf-www-service"
  protocol = "HTTP"

  backend {
    group = google_compute_instance_group.www-resources.self_link
  }

  health_checks = [google_compute_health_check.health-check.self_link]
}

#---------------Create backend service for Video Service---------------------
resource "google_compute_backend_service" "video-service" {
  name     = "tf-video-service"
  protocol = "HTTP"

  backend {
    group = google_compute_instance_group.video-resources.self_link
  }

  health_checks = [google_compute_health_check.health-check.self_link]
}

#---------------Create URL MAP----------------------
resource "google_compute_url_map" "web-map" {
  name            = "tf-web-map"
  default_service = google_compute_backend_service.www-service.self_link

  host_rule {
    hosts        = ["*"]
    path_matcher = "tf-allpaths"
  }

  path_matcher {
    name            = "tf-allpaths"
    default_service = google_compute_backend_service.www-service.self_link

    path_rule {
      paths   = ["/video", "/video/*"]
      service = google_compute_backend_service.video-service.self_link
    }
  }
}

#---------------Create Target Proxy (HTTP)----------------------
resource "google_compute_target_http_proxy" "http-lb-proxy" {
  name    = "tf-http-lb-proxy"
  url_map = google_compute_url_map.web-map.self_link
}

#---------------Create Forwadling rule----------------------
resource "google_compute_global_forwarding_rule" "default" {
  name       = "tf-http-content-gfr"
  target     = google_compute_target_http_proxy.http-lb-proxy.self_link
  ip_address = google_compute_global_address.external-address.address
  port_range = "80"
}

#---------------Open Firewall rule from Google Systems to allow health check----------------------
resource "google_compute_firewall" "default" {
  name    = "tf-www-firewall-allow-internal-only"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["http-tag"]
}
