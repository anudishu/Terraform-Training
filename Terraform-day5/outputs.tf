output "web_instance_name" {
    value= google_compute_instance.web1.id
}

output "web_private_ip" {
    value= google_compute_instance.web1.network_interface[0].network_ip
  
}