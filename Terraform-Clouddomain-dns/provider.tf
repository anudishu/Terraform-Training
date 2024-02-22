provider "google" {
  credentials = file("tcb-project-371706-4c5de465c0d5.json")
  project     = "tcb-project-371706" #Project A
  region      = "us-east1"
}