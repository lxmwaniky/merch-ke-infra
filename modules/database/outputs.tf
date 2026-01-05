output "db_instance_ip" {
  value       = google_sql_database_instance.postgres.private_ip_address
  description = "The private IP address of the SQL instance"
}

output "db_instance_name" {
  value       = google_sql_database_instance.postgres.name
  description = "The name of the SQL instance"
}