
#############################################################################
#                 multiple Provider  Block                                                    
#############################################################################
provider "google" {
  credentials = file("mindful-marking-388908-1bd361b00a4c.json")
  project     = "mindful-marking-388908" #Project A
  region      = "us-east1"
}

provider "google" {

  project     = "constant-goods-401703" # Project B
  region      = "us-east1"
  alias       = "gcp-service-project"
  credentials = file("constant-goods-401703-e57ff5b4fd65.json")
}

#############################################################################
#             Create VPC/Subnet/Compute in First Project:                                               
#############################################################################

resource "google_compute_network" "vpc1" {
  name                    = "my-custom-network-1"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "my-custom-subnet1" {
  name          = "my-custom-subnet-1"
  ip_cidr_range = "10.255.196.0/24"
  network       = google_compute_network.vpc1.name
  region        = "us-east1"
}

resource "google_compute_instance" "my_vm" {
  project      = "mindful-marking-388908"
  zone         = "us-east1-b"
  name         = "demo-1"
  machine_type = "e2-medium"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = "my-custom-network-1"
    subnetwork = google_compute_subnetwork.my-custom-subnet1.name # Replace with a reference or self link to your subnet, in quotes
  }
}


#############################################################################
#        Create second VPC/Subnet/compute in first Project:                                                              #
#############################################################################


resource "google_compute_network" "vpc2" {
  name                    = "my-custom-network-2"
  auto_create_subnetworks = "false"
}


resource "google_compute_subnetwork" "my-custom-subnet2" {
  name          = "my-custom-subnet-2"
  ip_cidr_range = "10.255.184.0/24"
  network       = google_compute_network.vpc2.name
  region        = "us-east1"
}


resource "google_compute_instance" "my_vm2" {
  project      = "mindful-marking-388908"
  zone         = "us-east1-b"
  name         = "demo-2"
  machine_type = "e2-medium"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = "my-custom-network-2"
    subnetwork = google_compute_subnetwork.my-custom-subnet2.name # Replace with a reference or self link to your subnet, in quotes
  }
}

#############################################################################
#     Create third VPC/Subnet/compute in Second Project:                                                                #
#############################################################################


resource "google_compute_network" "vpc3" {
  name                    = "my-custom-network-3"
  provider                = google.gcp-service-project
  auto_create_subnetworks = "false"

}


resource "google_compute_subnetwork" "my-custom-subnet3" {
  name          = "my-custom-subnet-3"
  ip_cidr_range = "10.255.186.0/24"
  network       = google_compute_network.vpc3.name
  region        = "us-east1"
  provider      = google.gcp-service-project
}


resource "google_compute_instance" "my_vm3" {
  project      = "constant-goods-401703"
  zone         = "us-east1-c"
  name         = "demo-3"
  machine_type = "e2-medium"
  provider     = google.gcp-service-project
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network    = "my-custom-network-3"
    subnetwork = google_compute_subnetwork.my-custom-subnet3.name # Replace with a reference or self link to your subnet, in quotes
  }
}



#############################################################################
#     Peering VPC1 <--> VPC2  and     VPC1 <--> VPC3                                                             #
#############################################################################

resource "google_compute_network_peering" "peering1" {
  name         = "peering1"
  network      = google_compute_network.vpc1.self_link
  peer_network = google_compute_network.vpc2.self_link
}

resource "google_compute_network_peering" "peering2" {
  name         = "peering2"
  network      = google_compute_network.vpc2.self_link
  peer_network = google_compute_network.vpc1.self_link
}

resource "google_compute_network_peering" "peering3" {
  name         = "peering3"
  network      = google_compute_network.vpc1.self_link
  peer_network = google_compute_network.vpc3.self_link
}

resource "google_compute_network_peering" "peering4" {
  name         = "peering4"
  provider     = google.gcp-service-project
  network      = google_compute_network.vpc3.self_link
  peer_network = google_compute_network.vpc1.self_link
}

#######################################################################################
#   Create firewalls for allow SSH from internet, allow icmp from VPC1 to VPC2 and VPC3
#######################################################################################

resource "google_compute_firewall" "rules" {
  project = "mindful-marking-388908"
  name    = "allow-ssh"
  network = "my-custom-network-1" # Replace with a reference or self link to your network, in quotes

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}


resource "google_compute_firewall" "rules1" {
  project = "mindful-marking-388908"
  name    = "allow-ssh1"
  network = "my-custom-network-2" # Replace with a reference or self link to your network, in quotes

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
}


##### create  Firewall to allow icmp from VPC1 to VPC3. such that on network VPC3
resource "google_compute_firewall" "allow-icmp-rule-vpc3" {
  project  = "constant-goods-401703"
  name     = "allow-icmp"
  network  = "my-custom-network-3" # Replace with a reference or self link to your network, in quotes
  provider = google.gcp-service-project

  allow {
    protocol = "icmp"

  }
  source_ranges = ["10.255.196.0/24"]
}























## Create IAP SSH permissions for your test instance

# resource "google_project_iam_member" "project" {
#   project = "mindful-marking-388908"
#   role    = "roles/iap.tunnelResourceAccessor"
#   member  = "serviceAccount:sa-demo@mindful-marking-388908.iam.gserviceaccount.com"
# }






