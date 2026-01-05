variable "project_id" {
  type        = string
  description = "The GCP project ID."

}

variable "app_name" {
  type        = string
  description = "The name of the application."

}

variable "env" {
  type        = string
  description = "The environment (e.g., dev, prod)."

}

variable "db_instance_name" {
  type        = string
  description = "The name of the SQL instance"
}