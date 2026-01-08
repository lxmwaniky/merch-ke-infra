# Merch-KE Infrastructure Operations Guide

Quick reference for common operations and commands.

---

## Quick Commands

### View Current State

```bash
# Show all deployed resources
terraform show

# List specific outputs
terraform output

# Show load balancer IP
terraform output load_balancer_ip
```

### Deploy Changes

```bash
# Preview changes
terraform plan

# Apply changes
terraform apply

# Apply without confirmation
terraform apply -auto-approve
```

### Destroy Infrastructure

```bash
# Preview destruction
terraform plan -destroy

# Destroy all resources
terraform destroy
```

---

## Container Image Updates

### Rebuild and Deploy Frontend

```bash
# Navigate to frontend project
cd ../merch-ke

# Build with Cloud Build
gcloud builds submit \
  --tag us-central1-docker.pkg.dev/musicstudy-ke/merch-repo/merch-ke-frontend:latest .

# Update Cloud Run service
gcloud run services update merch-ke-frontend-dev \
  --region=us-central1 \
  --image=us-central1-docker.pkg.dev/musicstudy-ke/merch-repo/merch-ke-frontend:latest
```

### Rebuild and Deploy Backend

```bash
# Navigate to backend project
cd ../merch-ke-api

# Build with Cloud Build
gcloud builds submit \
  --tag us-central1-docker.pkg.dev/musicstudy-ke/merch-repo/merch-ke-api:latest .

# Update Cloud Run service
gcloud run services update merch-ke-backend-dev \
  --region=us-central1 \
  --image=us-central1-docker.pkg.dev/musicstudy-ke/merch-repo/merch-ke-api:latest
```

---

## Logs and Monitoring

### View Cloud Run Logs

```bash
# Frontend logs
gcloud run services logs read merch-ke-frontend-dev --region=us-central1 --limit=50

# Backend logs
gcloud run services logs read merch-ke-backend-dev --region=us-central1 --limit=50

# Stream logs in real-time
gcloud run services logs tail merch-ke-backend-dev --region=us-central1
```

### View Cloud SQL Logs

```bash
gcloud sql instances list
gcloud logging read "resource.type=cloudsql_database" --limit=20
```

---

## Database Operations

### Get Database Password

```bash
gcloud secrets versions access latest --secret=merch-ke-db-app-password-dev
```

### Connect via Cloud SQL Studio

1. Go to [Cloud Console](https://console.cloud.google.com/sql)
2. Click **merch-ke-db**
3. Click **Cloud SQL Studio** (left sidebar)
4. Login:
   - Database: `merch-ke-db`
   - User: `app_user`
   - Password: (from Secret Manager)

### View Database Info

```bash
# Instance details
gcloud sql instances describe merch-ke-db

# List databases
gcloud sql databases list --instance=merch-ke-db

# List users
gcloud sql users list --instance=merch-ke-db
```

---

## Network Troubleshooting

### Check VPC Connector

```bash
gcloud compute networks vpc-access connectors describe merch-ke-vpc-connector \
  --region=us-central1
```

### Check Cloud SQL Connectivity

```bash
# From Cloud Shell (has VPC access)
gcloud sql connect merch-ke-db --database=merch-ke-db --user=app_user
```

### Test Load Balancer

```bash
# Test frontend
curl -I http://35.227.202.77/

# Test backend API
curl http://35.227.202.77/api/products

# Verbose output
curl -v http://35.227.202.77/api/health
```

---

## Secret Management

### View Secrets

```bash
# List all secrets
gcloud secrets list

# Get secret value
gcloud secrets versions access latest --secret=merch-ke-db-app-password-dev
```

### Rotate Database Password

```bash
# Create new secret version
echo -n "NEW_PASSWORD" | gcloud secrets versions add merch-ke-db-app-password-dev --data-file=-

# Update database user password
gcloud sql users set-password app_user \
  --instance=merch-ke-db \
  --password=NEW_PASSWORD

# Redeploy backend to pick up new secret
gcloud run services update merch-ke-backend-dev --region=us-central1
```

---

## Terraform Import

If resources exist in GCP but not in state (e.g., after interrupted apply):

```bash
# Import Load Balancer IP
terraform import 'module.loadbalancer.google_compute_global_address.default' \
  projects/musicstudy-ke/global/addresses/merch-ke-lb-ip-dev

# Import Cloud Run service
terraform import 'module.compute.google_cloud_run_v2_service.frontend' \
  projects/musicstudy-ke/locations/us-central1/services/merch-ke-frontend-dev

# Import VPC
terraform import 'module.network.google_compute_network.vpc' \
  projects/musicstudy-ke/global/networks/merch-ke-vpc
```

---

## Environment Variables

### Frontend (.env.production)

```env
NEXT_PUBLIC_API_BASE_URL=http://35.227.202.77
```

### Backend (from Terraform/Secret Manager)

```env
DB_HOST=10.95.0.3
DB_PORT=5432
DB_NAME=merch-ke-db
DB_USER=app_user
DB_PASSWORD=<from-secret-manager>
DB_SSLMODE=disable
```

---

## Cost Monitoring

```bash
# View current billing
gcloud billing accounts list

# Get cost breakdown (requires Billing API)
# Go to: https://console.cloud.google.com/billing
```

### Approximate Monthly Costs

| Resource | Cost |
|----------|------|
| Cloud Run (scale to zero) | ~$5-20 |
| Cloud SQL (db-f1-micro) | ~$10 |
| VPC Connector (2x e2-micro) | ~$15 |
| Load Balancer | ~$20 |
| Network Egress | ~$5-10 |
| **Total (dev)** | **~$50-75** |

---

## Useful Links

- [GCP Console](https://console.cloud.google.com/home/dashboard?project=musicstudy-ke)
- [Cloud Run Services](https://console.cloud.google.com/run?project=musicstudy-ke)
- [Cloud SQL](https://console.cloud.google.com/sql?project=musicstudy-ke)
- [Secret Manager](https://console.cloud.google.com/security/secret-manager?project=musicstudy-ke)
- [Load Balancing](https://console.cloud.google.com/net-services/loadbalancing?project=musicstudy-ke)
- [VPC Networks](https://console.cloud.google.com/networking/networks?project=musicstudy-ke)
