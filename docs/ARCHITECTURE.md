# Merch-KE Infrastructure Architecture

This document provides an in-depth technical reference for the Merch-KE infrastructure deployed on Google Cloud Platform.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Network Architecture](#network-architecture)
3. [Compute Architecture](#compute-architecture)
4. [Database Architecture](#database-architecture)
5. [Security Architecture](#security-architecture)
6. [Load Balancer Architecture](#load-balancer-architecture)
7. [Data Flow](#data-flow)
8. [Module Dependencies](#module-dependencies)

---

## Architecture Overview

```
                                    ┌─────────────────────────────────────────────────────────────┐
                                    │                    GOOGLE CLOUD PLATFORM                    │
                                    │                     Project: musicstudy-ke                  │
┌──────────┐                        │  ┌─────────────────────────────────────────────────────┐   │
│          │                        │  │              Global HTTP(S) Load Balancer            │   │
│  Users   │───────HTTP/S──────────▶│  │                   IP: 35.227.202.77                  │   │
│          │                        │  │    ┌─────────────┐         ┌─────────────┐          │   │
└──────────┘                        │  │    │   /*        │         │   /api/*    │          │   │
                                    │  │    │   Frontend  │         │   Backend   │          │   │
                                    │  │    └──────┬──────┘         └──────┬──────┘          │   │
                                    │  └───────────┼───────────────────────┼──────────────────┘   │
                                    │              │                       │                      │
                                    │  ┌───────────▼───────────────────────▼──────────────────┐   │
                                    │  │                   Cloud Run (us-central1)            │   │
                                    │  │  ┌────────────────────┐  ┌────────────────────┐      │   │
                                    │  │  │  merch-ke-frontend │  │  merch-ke-backend  │      │   │
                                    │  │  │     (Next.js)      │  │    (Go Fiber)      │      │   │
                                    │  │  │     Port 8080      │  │     Port 8080      │      │   │
                                    │  │  └────────────────────┘  └─────────┬──────────┘      │   │
                                    │  │           Ingress: Internal + Load Balancer          │   │
                                    │  └────────────────────────────────────┼──────────────────┘   │
                                    │                                       │                      │
                                    │  ┌────────────────────────────────────┼──────────────────┐   │
                                    │  │              VPC: merch-ke-vpc                        │   │
                                    │  │  ┌─────────────────────────────────┼──────────────┐   │   │
                                    │  │  │     Serverless VPC Connector    │              │   │   │
                                    │  │  │          10.8.0.0/28            │              │   │   │
                                    │  │  │     (2-3 e2-micro instances)    │              │   │   │
                                    │  │  └─────────────────────────────────┼──────────────┘   │   │
                                    │  │                                    │                  │   │
                                    │  │  ┌─────────────────────────────────┼──────────────┐   │   │
                                    │  │  │        Compute Subnet           │              │   │   │
                                    │  │  │          10.0.1.0/24            │              │   │   │
                                    │  │  │  (Private Google Access: ON)    │              │   │   │
                                    │  │  └─────────────────────────────────┼──────────────┘   │   │
                                    │  │                                    │                  │   │
                                    │  │  ┌─────────────────────────────────┼──────────────┐   │   │
                                    │  │  │    Private Service Access       │              │   │   │
                                    │  │  │         10.95.0.0/16            │              │   │   │
                                    │  │  │   (VPC Peering to Google)       │              │   │   │
                                    │  │  └─────────────────────────────────┼──────────────┘   │   │
                                    │  └────────────────────────────────────┼──────────────────┘   │
                                    │                                       │                      │
                                    │  ┌────────────────────────────────────▼──────────────────┐   │
                                    │  │            Google-Managed Service Producer Network    │   │
                                    │  │  ┌────────────────────────────────────────────────┐   │   │
                                    │  │  │              Cloud SQL (PostgreSQL 15)         │   │   │
                                    │  │  │              Instance: merch-ke-db             │   │   │
                                    │  │  │              Private IP: 10.95.0.3             │   │   │
                                    │  │  │              Database: merch-ke-db             │   │   │
                                    │  │  │              User: app_user                    │   │   │
                                    │  │  └────────────────────────────────────────────────┘   │   │
                                    │  └───────────────────────────────────────────────────────┘   │
                                    │                                                              │
                                    │  ┌───────────────────────────────────────────────────────┐   │
                                    │  │                    Secret Manager                     │   │
                                    │  │         merch-ke-db-app-password-dev                  │   │
                                    │  └───────────────────────────────────────────────────────┘   │
                                    └──────────────────────────────────────────────────────────────┘
```

---

## Network Architecture

### VPC Configuration

| Property | Value |
|----------|-------|
| VPC Name | `merch-ke-vpc` |
| Routing Mode | Regional |
| Auto-create Subnets | No (custom mode) |

### Subnets

| Subnet | CIDR | Region | Purpose |
|--------|------|--------|---------|
| Compute | `10.0.1.0/24` | us-central1 | Cloud Run egress (via connector) |
| VPC Connector | `10.8.0.0/28` | us-central1 | Serverless VPC Access |
| Private Services | `10.95.0.0/16` | - | Cloud SQL (VPC peering) |

### VPC Access Connector

The Serverless VPC Access Connector bridges Cloud Run (which runs outside your VPC) to resources inside your VPC (like Cloud SQL with private IP).

```
Cloud Run ──▶ VPC Connector (10.8.0.0/28) ──▶ VPC ──▶ Cloud SQL (10.95.0.3)
```

| Property | Value |
|----------|-------|
| Name | `merch-ke-vpc-connector` |
| CIDR | `10.8.0.0/28` (16 IPs) |
| Min Instances | 2 |
| Max Instances | 3 |
| Machine Type | `e2-micro` |
| Throughput | 200-300 Mbps |

### Private Service Access

Cloud SQL uses **Private Service Access** (VPC Peering) to get a private IP from a reserved range:

1. Reserve IP range: `10.95.0.0/16` in your VPC
2. Create peering connection to `servicenetworking.googleapis.com`
3. Cloud SQL allocates private IP from this range

---

## Compute Architecture

### Cloud Run Services

Both services run on Cloud Run with identical configuration patterns:

#### Frontend Service

| Property | Value |
|----------|-------|
| Service Name | `merch-ke-frontend-dev` |
| Image | `us-central1-docker.pkg.dev/musicstudy-ke/merch-repo/merch-ke-frontend:latest` |
| Port | 8080 |
| CPU | 1 |
| Memory | 512Mi |
| Min Instances | 0 (scale to zero) |
| Max Instances | 10 |
| Ingress | Internal + Load Balancer only |
| VPC Connector | Connected (all traffic) |

#### Backend Service

| Property | Value |
|----------|-------|
| Service Name | `merch-ke-backend-dev` |
| Image | `us-central1-docker.pkg.dev/musicstudy-ke/merch-repo/merch-ke-api:latest` |
| Port | 8080 |
| CPU | 1 |
| Memory | 512Mi |
| Min Instances | 0 |
| Max Instances | 10 |
| Ingress | Internal + Load Balancer only |
| VPC Connector | Connected (all traffic) |
| Service Account | `merch-ke-backend-sa-dev@musicstudy-ke.iam.gserviceaccount.com` |

#### Backend Environment Variables

| Variable | Source |
|----------|--------|
| `DB_HOST` | Terraform output (10.95.0.3) |
| `DB_PORT` | 5432 |
| `DB_NAME` | merch-ke-db |
| `DB_USER` | app_user |
| `DB_PASSWORD` | Secret Manager reference |
| `DB_SSLMODE` | disable (private network) |

---

## Database Architecture

### Cloud SQL Instance

| Property | Value |
|----------|-------|
| Instance Name | `merch-ke-db` |
| Database Version | PostgreSQL 15 |
| Tier | `db-f1-micro` (dev) |
| Region | us-central1 |
| Availability | Single zone (dev) |
| Storage | 10 GB SSD |
| Backups | Enabled, daily |
| Point-in-time Recovery | Enabled |
| Public IP | **Disabled** |
| Private IP | 10.95.0.3 |
| SSL | Required for public (N/A) |

### Database Schema

The database uses PostgreSQL schemas for logical separation:

| Schema | Purpose | Tables |
|--------|---------|--------|
| `catalog` | Product data | products, categories, variants, images |
| `auth` | User management | users, addresses, sessions |
| `orders` | Transactions | orders, order_items, payments |

### Users

| User | Purpose | Access |
|------|---------|--------|
| `postgres` | Admin | Full (root) |
| `app_user` | Application | CRUD on app schemas |

---

## Security Architecture

### IAM Service Accounts

| Service Account | Purpose | Roles |
|-----------------|---------|-------|
| `merch-ke-backend-sa-dev` | Backend Cloud Run | Cloud SQL Client, Secret Accessor |

### Secrets Management

| Secret | Purpose | Accessor |
|--------|---------|----------|
| `merch-ke-db-app-password-dev` | Database password | Backend SA |

### Network Security

1. **No Public IPs**: Database and internal services have no public exposure
2. **VPC Isolation**: All compute traffic routes through VPC connector
3. **Ingress Control**: Cloud Run only accepts traffic from Load Balancer
4. **Private Peering**: Database accessible only via VPC peering

### Cloud Armor (Optional)

The security module includes commented Cloud Armor policies for:
- Rate limiting (100 req/min)
- SQL injection blocking
- XSS attack prevention
- DDoS mitigation

---

## Load Balancer Architecture

### Global HTTP(S) Load Balancer

| Component | Resource |
|-----------|----------|
| IP Address | `google_compute_global_address` (35.227.202.77) |
| Frontend NEG | `google_compute_region_network_endpoint_group` (serverless) |
| Backend NEG | `google_compute_region_network_endpoint_group` (serverless) |
| Frontend Backend | `google_compute_backend_service` |
| API Backend | `google_compute_backend_service` |
| URL Map | `google_compute_url_map` |
| HTTP Proxy | `google_compute_target_http_proxy` |
| Forwarding Rule | `google_compute_global_forwarding_rule` (port 80) |

### URL Routing

```
http://35.227.202.77/*        →  Frontend Cloud Run
http://35.227.202.77/api/*    →  Backend Cloud Run
```

The URL map uses path matching:

```hcl
path_matcher {
  name            = "allpaths"
  default_service = frontend_backend_service  # Catch-all

  path_rule {
    paths   = ["/api/*"]
    service = api_backend_service
  }
}
```

**Important**: Paths are passed to backends **as-is** (not stripped). The backend receives `/api/products`, not `/products`.

---

## Data Flow

### User Request Flow

```
1. User → Browser → http://35.227.202.77/products
2. DNS → Global Anycast IP (35.227.202.77)
3. Google Frontend → Load Balancer
4. URL Map → Path "/" → Frontend Backend Service
5. Backend Service → Frontend NEG → Cloud Run
6. Cloud Run → merch-ke-frontend-dev container
7. Response flows back through same path
```

### API Request Flow

```
1. Frontend JS → fetch("/api/products")
2. Load Balancer → URL Map → Path "/api/*" → API Backend Service
3. Backend Service → Backend NEG → Cloud Run
4. Cloud Run → merch-ke-backend-dev container
5. Container → VPC Connector (10.8.0.0/28)
6. VPC Connector → Private Service Access (10.95.0.0/16)
7. Private Network → Cloud SQL (10.95.0.3)
8. Database query → Response
9. Response flows back through same path
```

---

## Module Dependencies

```
                    ┌──────────────┐
                    │   provider   │
                    │   (GCP APIs) │
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │   network    │
                    │  (VPC, Conn) │
                    └──────┬───────┘
                           │
              ┌────────────┼────────────┐
              │            │            │
       ┌──────▼─────┐     │     ┌──────▼─────┐
       │  database  │     │     │    iam     │
       │ (Cloud SQL)│     │     │ (SA, Roles)│
       └──────┬─────┘     │     └──────┬─────┘
              │           │            │
              └───────────┼────────────┘
                          │
                   ┌──────▼───────┐
                   │   compute    │
                   │ (Cloud Run)  │
                   └──────┬───────┘
                          │
                   ┌──────▼───────┐
                   │ loadbalancer │
                   │   (GLB, IP)  │
                   └──────────────┘
```

### Dependency Explanation

1. **Network** must be created first (VPC, connector, peering)
2. **Database** depends on network (needs peering for private IP)
3. **IAM** depends on network (service accounts can be parallel)
4. **Compute** depends on all three (needs connector, DB IP, SA)
5. **Load Balancer** depends on compute (needs Cloud Run services)

---

## Terraform State

The infrastructure state is stored locally in:
- `terraform.tfstate` - Current state
- `terraform.tfstate.backup` - Previous state

**Recommendation**: For production, migrate to remote state:

```hcl
terraform {
  backend "gcs" {
    bucket = "merch-ke-terraform-state"
    prefix = "terraform/state"
  }
}
```

---

## Resource Naming Convention

All resources follow the pattern:

```
{app_name}-{resource_type}-{env}
```

Examples:
- `merch-ke-vpc-dev`
- `merch-ke-backend-dev`
- `merch-ke-db-app-password-dev`

This allows multiple environments (dev, staging, prod) to coexist in the same project.
