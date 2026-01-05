resource "google_sql_database_instance" "postgres" {
  name             = var.db_name
  database_version = "POSTGRES_15"
  region           = var.region

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_id
      enable_private_path_for_google_cloud_services = true
    }
  }

  # Best Practice: Keep this false while learning so you can delete easily. 
  # In PROD, always set to true!
  deletion_protection = true
}

# actual database inside the instance
resource "google_sql_database" "app_db" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres.name
}
