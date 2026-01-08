output "backend_sa_email" {
  value = google_service_account.backend_sa.email
}

output "db_password_secret_id" {
  value       = google_secret_manager_secret.db_password.secret_id
  description = "The secret ID for the database password"
}