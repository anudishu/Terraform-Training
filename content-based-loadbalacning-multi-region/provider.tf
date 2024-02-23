provider "google" {
  region      = "us-east1"
  project     = "mindful-marking-388908"
  credentials = file("key.json")

}

provider "google" {

  project     = "mindful-marking-388908"
  region      = "europe-west1"
  alias       = "gcp-region-europe-west" #Region Europe-west
  credentials = file("key.json")

}