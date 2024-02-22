# Provider
provider "google" {
  credentials = file("host-project-375410-c25c379d9e10.json")
  project     = "host-project-375410"
  region      = "us-east1"
}

# Fetch Organization name
data "google_organization" "org" {
  domain = "lyfedge.com"

}

# Create an access policy scoped to folder. thats is "BU1"  
resource "google_access_context_manager_access_policy" "org-policy" {
  parent = data.google_organization.org.name
  title  = "Parent policy for ACL restrictions"
  scopes = ["folders/741128092978"]  # replace the numbber with your folder ID
}

# Create Service Perimeter resource to the specific projects. Protected projects.
resource "google_access_context_manager_service_perimeter_resource" "service-perimeter-resource" {
  perimeter_name = google_access_context_manager_service_perimeter.service-perimeter.name
  resource = "projects/654385628748" #  (Required) A GCP resource that is inside of the service perimeter. Currently only projects are allowed. Format: projects/{project_number}
}

# Create a service perimeter to protect google cloud storage API within the access policy
resource "google_access_context_manager_service_perimeter" "service-perimeter" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.org-policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.org-policy.name}/servicePerimeters/restrict_storage"
  title  = "restrict_storage"
  perimeter_type = "PERIMETER_TYPE_REGULAR"
  status {
    restricted_services = ["storage.googleapis.com"]
   
  }
  
}

# Create Access level to block the access from certain Geo-location.

 resource "google_access_context_manager_access_levels" "access-levels" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.org-policy.name}"
  access_levels {
    name   = "accessPolicies/${google_access_context_manager_access_policy.org-policy.name}/accessLevels/chromeos_no_lock"
    title  = "regions-block"
    basic {
      conditions {

        regions = [
    "CH",
    "IT",
    "US",
    "IN",
    
        ]
      }
    }
  }

  }
