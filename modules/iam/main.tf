resource "google_service_account" "backend_sa" {
  account_id = "${var.app_name}-backend-${var.env}"
  display_name = "Service Account for Go Backend"
}

resource "google_project_iam_member" "sql_client" {
  project = var.project_id
  role = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.backend_sa.email}"
}

# Create a slot for the DB Password
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"
  replication {
    auto {}
  }
}

# Give the Go Backend permission to READ this secret
resource "google_secret_manager_secret_iam_member" "secret_reader" {
  secret_id = google_secret_manager_secret.db_password.id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.backend_sa.email}"
}