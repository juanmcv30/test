output "external_ip" {
  value = google_compute_instance.vm.network_interface.0.access_config.0.nat_ip
}

output "admin_username" {
  value = var.admin_username
}
output "admin_password" {
  value = random_password.password.result
  sensitive = true
}
