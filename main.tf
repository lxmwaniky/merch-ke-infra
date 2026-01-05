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
  source     = "./modules/iam"
  project_id = var.project_id
  app_name   = var.app_name
  env        = var.env
}