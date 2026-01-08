variable "project_id" {
  type        = string
  description = "The GCP project ID."
}

variable "region" {
  type        = string
  description = "The GCP region."
}

variable "app_name" {
  type        = string
  description = "The name of the application."
}

variable "env" {
  type        = string
  description = "The environment (e.g., dev, prod)."
}

variable "domain" {
  type        = string
  description = "The domain name for SSL certificate (optional)."
  default     = ""
}

variable "frontend_service_name" {
  type        = string
  description = "The name of the frontend Cloud Run service."
}

variable "backend_service_name" {
  type        = string
  description = "The name of the backend Cloud Run service."
}
