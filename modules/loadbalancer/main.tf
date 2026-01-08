resource "google_compute_global_address" "default" {
  name = "${var.app_name}-lb-ip-${var.env}"
}

resource "google_compute_region_network_endpoint_group" "frontend_neg" {
  name                  = "${var.app_name}-frontend-neg-${var.env}"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.frontend_service_name
  }
}

resource "google_compute_region_network_endpoint_group" "backend_neg" {
  name                  = "${var.app_name}-backend-neg-${var.env}"
  network_endpoint_type = "SERVERLESS"
  region                = var.region

  cloud_run {
    service = var.backend_service_name
  }
}

resource "google_compute_backend_service" "frontend" {
  name                  = "${var.app_name}-frontend-backend-${var.env}"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.frontend_neg.id
  }
}

resource "google_compute_backend_service" "backend" {
  name                  = "${var.app_name}-api-backend-${var.env}"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group = google_compute_region_network_endpoint_group.backend_neg.id
  }
}

resource "google_compute_url_map" "default" {
  name            = "${var.app_name}-url-map-${var.env}"
  default_service = google_compute_backend_service.frontend.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.frontend.id

    path_rule {
      paths   = ["/api/*"]
      service = google_compute_backend_service.backend.id
    }
  }
}

resource "google_compute_managed_ssl_certificate" "default" {
  count = var.domain != "" ? 1 : 0
  name  = "${var.app_name}-ssl-cert-${var.env}"

  managed {
    domains = [var.domain]
  }
}

resource "google_compute_target_https_proxy" "default" {
  count   = var.domain != "" ? 1 : 0
  name    = "${var.app_name}-https-proxy-${var.env}"
  url_map = google_compute_url_map.default.id
  ssl_certificates = [google_compute_managed_ssl_certificate.default[0].id]
}

resource "google_compute_target_http_proxy" "default" {
  name    = "${var.app_name}-http-proxy-${var.env}"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_global_forwarding_rule" "https" {
  count                 = var.domain != "" ? 1 : 0
  name                  = "${var.app_name}-https-rule-${var.env}"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.default[0].id
  ip_address            = google_compute_global_address.default.id
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${var.app_name}-http-rule-${var.env}"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}
