provider "google" {
  credentials = file("<YOUR-CREDENTIALS-FILE>.json")
  project     = "<YOUR-PROJECT-ID>"
  region      = "<YOUR-REGION>"
}

# Optionally, specify a terraform backend to store state
terraform {
  backend "gcs" {
    bucket  = "<YOUR-TERRAFORM-STATE-BUCKET>"
    prefix  = "terraform/state"
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
