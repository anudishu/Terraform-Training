# Host Project:
provider "google" {
  credentials = file("host-project.json")
  project     = var.host_project #Project A
  region      = "asia-south2"
}


























# # Service Project1
# provider "google" {
#   credentials = file("sustained-spark-393903-3087ddb8c168.json")
#   project     = var.service_project1# Service Project 1
#   region      = "asia-south2"
#   alias       = "gcp-service-project1"
# }

# # Service Project2
# provider "google" {
#   credentials = file("constant-goods-401703-06d3cf16ca36.json")
#   project     = var.service_project1#Project A
#   region      = "asia-south2"
#   alias       = "gcp-service-project2"
# }