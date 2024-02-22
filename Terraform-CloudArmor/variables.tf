variable "region" {
  default = "us-west1"
}

variable "region_zone" {
  default = "us-west1-a"
}

variable "project_name" {
  default     = "sustained-spark-393903"
  description = "The ID of the Google Cloud project"
}

variable "credentials_file_path" {
  description = "Path to the JSON file used to describe your account credentials"
  default     = "key.json"
}

variable "ip_white_list" {
  description = "A list of ip addresses that can be white listed through security policies"
  default     = ["103.208.68.139/32"]
}
