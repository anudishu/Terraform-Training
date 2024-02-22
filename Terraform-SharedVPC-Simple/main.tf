
# To Enable A Shared VPC in host project
resource "google_compute_shared_vpc_host_project" "host" {
  project = var.host_project 
  
}

# To attch a service project with host project 
resource "google_compute_shared_vpc_service_project" "service1" {
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = var.service_project1 
}

#To attch a service project with host project 
resource "google_compute_shared_vpc_service_project" "service2" {
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = var.service_project2 
}


# Shared Network to attach 
data "google_compute_network" "network" {
  name    = "vpc-1"
  project = var.host_project
}


# Shared Sub-Network to attach 
data "google_compute_subnetwork" "subnet1" {
  name    = "subnet1-newdelhi"
  project = var.host_project
  region  = "asia-south2"
}

data "google_compute_subnetwork" "subnet2" {
  name    = "subnet2-us-central"
  project = var.host_project
  region  = "us-central1"
}
#################################################################################################
#                 Create VMs in the Shared VPC Subnets in the service projects.
#################################################################################################


# Create VM in first Service Project: 
resource "google_compute_instance" "vm_machine1" {
  project      = var.service_project1
  zone         = "asia-south2-a"
  name         = "my-demo-vm-1"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = data.google_compute_subnetwork.subnet1.id

  }
  depends_on = [google_compute_shared_vpc_host_project.host,
                google_compute_shared_vpc_service_project.service1,
                google_compute_shared_vpc_service_project.service2
              
               ]
}

# Create a VM in second Service Project
resource "google_compute_instance" "vm_machine2" {
  project      = var.service_project2
  zone         = "us-central1-a"
  name         = "my-demo-vm-2"
  machine_type = "e2-medium"
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = data.google_compute_subnetwork.subnet2.id

  }
  depends_on = [google_compute_shared_vpc_host_project.host,
                google_compute_shared_vpc_service_project.service1,
                google_compute_shared_vpc_service_project.service2
              
               ]
}