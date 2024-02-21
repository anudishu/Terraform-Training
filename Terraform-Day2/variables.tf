variable "project_name" {
  description = "This is my Google Cloud Project"
  type        = string
  default     = "mindful-marking-388908"

}

variable "region_name" {
  description = "Region"
  type        = string
  default     = "us-central1"

}

variable "zone_name" {
  description = "Zone"
  type        = string
  default     = "us-central1-b"

}



#------------- Storage Variables-----------

variable "storage_name" {
  default = "mindful-marking-388908-auto-expiring-bucket"

}

#------------- Compute Variables-----------

variable "vm_name" {
  default = "web-instance"

}

variable "machine_type" {
  default = "g1.small"
}

