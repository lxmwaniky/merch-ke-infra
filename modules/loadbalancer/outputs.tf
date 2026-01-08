output "load_balancer_ip" {
  value       = google_compute_global_address.default.address
  description = "The public IP address of the load balancer"
}

output "http_url" {
  value       = "http://${google_compute_global_address.default.address}"
  description = "The HTTP URL of the load balancer"
}

output "https_url" {
  value       = var.domain != "" ? "https://${var.domain}" : null
  description = "The HTTPS URL (if domain is configured)"
}
