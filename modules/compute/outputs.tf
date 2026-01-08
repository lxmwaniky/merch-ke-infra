output "frontend_service_name" {
  value       = google_cloud_run_v2_service.frontend.name
  description = "The name of the frontend Cloud Run service"
}

output "frontend_service_uri" {
  value       = google_cloud_run_v2_service.frontend.uri
  description = "The URI of the frontend Cloud Run service"
}

output "backend_service_name" {
  value       = google_cloud_run_v2_service.backend.name
  description = "The name of the backend Cloud Run service"
}

output "backend_service_uri" {
  value       = google_cloud_run_v2_service.backend.uri
  description = "The URI of the backend Cloud Run service"
}
