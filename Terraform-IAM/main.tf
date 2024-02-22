
# Varibales
variable "project" {
    default = "mindful-marking-388908"
}

variable "region" {
    default = "us-central1"
}
##########################################



provider "google" {
  credentials = file("key.json")
  project     = var.project
  region      = var.region
}




# Optionally, specify a terraform backend to store state
terraform {
  backend "gcs" {
    bucket  = "<my-demo-bucket"
    prefix  = "terraform/iam.tfstate"
  }
}



# Create a Service Account 
resource "google_service_account" "compute_admin" {
  account_id   = "compute-admin-account"
  display_name = "Compute Admin Service Account"
}

#Create a Role Compute Admin and attach to Service Account 
resource "google_project_iam_member" "compute_admin_role" {
  project = "<YOUR-PROJECT-ID>"
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.compute_admin.email}"
}


# Create some custom Role for more granual approach of principal of list privilege 
resource "google_project_iam_custom_role" "limited_compute_role" {
  role_id     = "LimitedComputeRole"
  title       = "Limited Compute Role"
  description = "Can start and stop compute instances"
  permissions = [
    "compute.instances.start",
    "compute.instances.stop"
  ]
}

# create Second Service Account 
resource "google_service_account" "limited_compute_sa" {
  account_id   = "limited-compute-account"
  display_name = "Limited Compute Service Account"
}

# Attach or bind the custom role with  Second service Account  
resource "google_project_iam_member" "limited_compute_role_binding" {
  project = var.project
  role    = "projects/${var.project}/roles/LimitedComputeRole"
  member  = "serviceAccount:${google_service_account.limited_compute_sa.email}"
}
