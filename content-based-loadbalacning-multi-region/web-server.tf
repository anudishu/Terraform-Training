#####################################################################################################
#       umnaged IG, Compute VM and firewall us-east1
#####################################################################################################
resource "google_compute_instance_group" "webservers" {
  name        = "terraform-webservers-us"
  description = "Terraform test instance group"
  zone        = "us-east1-b"

  instances = [
    google_compute_instance.default.id

  ]
  named_port {
    name = "http"
    port = "80"
  }

}

resource "google_compute_instance" "default" {
  name         = "web1"
  machine_type = "g1-small"
  zone         = "us-east1-b"

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
  metadata_startup_script = file("web1.sh")

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

#####################################################################################################
#       umnaged IG, Compute VM us-east1
#####################################################################################################
resource "google_compute_instance_group" "webservers1" {
  name        = "terraform-webservers-us-video"
  description = "Terraform test instance group"
  zone        = "us-east1-b"

  instances = [
    google_compute_instance.default1.id

  ]
  named_port {
    name = "http"
    port = "80"
  }

}

resource "google_compute_instance" "default1" {
  name         = "web2"
  machine_type = "g1-small"
  zone         = "us-east1-b"

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
  metadata_startup_script = file("web2.sh")

}

#####################################################################################################
#       umnaged IG, Compute VM europe-west
#####################################################################################################
resource "google_compute_instance_group" "webservers2" {
  name        = "terraform-webservers-europe"
  description = "Terraform test instance group"
  zone        = "europe-west1-b"
  provider    = google.gcp-region-europe-west

  instances = [
    google_compute_instance.default2.id

  ]
  named_port {
    name = "http"
    port = "80"
  }

}

resource "google_compute_instance" "default2" {
  name         = "web3"
  machine_type = "g1-small"
  zone         = "europe-west1-b"
  provider     = google.gcp-region-europe-west

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
  metadata_startup_script = file("web1.sh")
}

#####################################################################################################
#       umnaged IG, Compute VM europe-west
#####################################################################################################
resource "google_compute_instance_group" "webservers3" {
  name        = "terraform-webservers-europe-video"
  description = "Terraform test instance group"
  zone        = "europe-west1-b"
  provider    = google.gcp-region-europe-west

  instances = [
    google_compute_instance.default3.id

  ]
  named_port {
    name = "http"
    port = "80"
  }

}

resource "google_compute_instance" "default3" {
  name         = "web4"
  machine_type = "g1-small"
  zone         = "europe-west1-b"
  provider     = google.gcp-region-europe-west

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
  metadata_startup_script = file("web2.sh")
}

######################################################################################################
##  Global HTTP Load Balancer, a configuration of LB resources
#######################################################################################################

# Forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "global-rule"
  target                = google_compute_target_http_proxy.default.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
# Target Proxy
resource "google_compute_target_http_proxy" "default" {
  name        = "target-proxy"
  description = "a description"
  url_map     = google_compute_url_map.default.id
}

#URL MAP and Routing Rule
resource "google_compute_url_map" "default" {
  name            = "url-map-target-proxy"
  description     = "a description"
  default_service = google_compute_backend_service.default.id

  host_rule {
    hosts        = ["lyfedge.com"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.default.id

    path_rule {
      paths   = ["/*"]
      service = google_compute_backend_service.default.id
    }
    path_rule {
      paths   = ["/app1/*"]
      service = google_compute_backend_service.default.id
    }
    path_rule {
      paths   = ["/app2/*"]
      service = google_compute_backend_service.default1.id
    }
  }

}

# Backend Service 1

resource "google_compute_backend_service" "default" {
  name                  = "backend"
  port_name             = "http"
  protocol              = "HTTP"
  timeout_sec           = 10
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.default1.id]
  backend {
    group           = google_compute_instance_group.webservers.id
    balancing_mode  = "UTILIZATION"
    max_utilization = 1.0
    capacity_scaler = 1.0
  }
  backend {
    group           = google_compute_instance_group.webservers2.id
    balancing_mode  = "UTILIZATION"
    max_utilization = 1.0
    capacity_scaler = 1.0
  }
}

# Backend Service 2
resource "google_compute_backend_service" "default1" {
  name                  = "backend-video"
  port_name             = "http"
  protocol              = "HTTP"
  timeout_sec           = 10
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.default1.id]
  backend {
    group           = google_compute_instance_group.webservers1.id
    balancing_mode  = "UTILIZATION"
    max_utilization = 1.0
    capacity_scaler = 1.0
  }
  backend {
    group           = google_compute_instance_group.webservers3.id
    balancing_mode  = "UTILIZATION"
    max_utilization = 1.0
    capacity_scaler = 1.0
  }

}

# Appllication Health check.
resource "google_compute_health_check" "default1" {
  name               = "tcp-proxy-health-check1"
  timeout_sec        = 1
  check_interval_sec = 1

  tcp_health_check {
    port = "80"
  }
}