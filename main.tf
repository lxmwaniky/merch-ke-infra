resource "google_project_service" "services" {
  for_each = toset([
    "secretmanager.googleapis.com",
    "run.googleapis.com",
    "vpcaccess.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}

module "network" {
  source              = "./modules/network"
  project_id          = var.project_id
  region              = var.region
  vpc_name            = var.vpc_name
  subnet_compute_cidr = var.subnet_compute_cidr
  vpc_connector_cidr  = var.vpc_connector_cidr
}

module "database" {
  source     = "./modules/database"
  project_id = var.project_id
  region     = var.region
  db_name    = var.db_name
  network_id = module.network.network_id

  # CRITICAL: The DB cannot be created until the Network Tunnel is finished!
  depends_on = [module.network]
}

module "iam" {
  source           = "./modules/iam"
  project_id       = var.project_id
  app_name         = var.app_name
  env              = var.env
  db_instance_name = module.database.db_instance_name
}

module "compute" {
  source = "./modules/compute"

  project_id       = var.project_id
  region           = var.region
  app_name         = var.app_name
  env              = var.env

  vpc_connector_id      = module.network.connector_id
  backend_sa_email      = module.iam.backend_sa_email
  db_host               = module.database.db_instance_ip
  db_name               = var.db_name
  db_password_secret_id = module.iam.db_password_secret_id

  # Optional: Override default placeholder images
  # frontend_image = "us-central1-docker.pkg.dev/your-project/repo/frontend:latest"
  # backend_image  = "us-central1-docker.pkg.dev/your-project/repo/backend:latest"

  depends_on = [module.iam, module.database, module.network]
}