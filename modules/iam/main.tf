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

resource "random_password" "db_pass" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "google_secret_manager_secret_version" "db_password_val" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_pass.result
}

resource "google_sql_user" "db_user" {
  name     = "app_user"
  instance = var.db_instance_name # We'll need to pass this in!
  password = random_password.db_pass.result
}