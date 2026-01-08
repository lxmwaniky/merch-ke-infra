# =============================================================================
# Security Module - Cloud Armor & WAF (Optional)
# =============================================================================
# This module provides security policies for the load balancer.
# Cloud Armor provides DDoS protection and WAF capabilities.
#
# To enable, uncomment the resources below and add the security_policy
# to the backend services in the loadbalancer module.
# =============================================================================

# Uncomment to enable Cloud Armor security policy
#
# resource "google_compute_security_policy" "default" {
#   name        = "${var.app_name}-security-policy-${var.env}"
#   description = "Security policy for ${var.app_name}"
#
#   # Default rule - allow all traffic
#   rule {
#     action   = "allow"
#     priority = "2147483647"
#     match {
#       versioned_expr = "SRC_IPS_V1"
#       config {
#         src_ip_ranges = ["*"]
#       }
#     }
#     description = "Default rule - allow all"
#   }
#
#   # Rate limiting rule
#   rule {
#     action   = "rate_based_ban"
#     priority = "1000"
#     match {
#       versioned_expr = "SRC_IPS_V1"
#       config {
#         src_ip_ranges = ["*"]
#       }
#     }
#     rate_limit_options {
#       conform_action = "allow"
#       exceed_action  = "deny(429)"
#       rate_limit_threshold {
#         count        = 100
#         interval_sec = 60
#       }
#       ban_duration_sec = 300
#     }
#     description = "Rate limit - 100 requests per minute"
#   }
#
#   # Block common attack patterns (SQL injection, XSS)
#   rule {
#     action   = "deny(403)"
#     priority = "100"
#     match {
#       expr {
#         expression = "evaluatePreconfiguredExpr('sqli-stable')"
#       }
#     }
#     description = "Block SQL injection attacks"
#   }
#
#   rule {
#     action   = "deny(403)"
#     priority = "101"
#     match {
#       expr {
#         expression = "evaluatePreconfiguredExpr('xss-stable')"
#       }
#     }
#     description = "Block XSS attacks"
#   }
# }
