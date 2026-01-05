module "network" {
  source              = "./modules/network"
  project_id          = var.project_id
  region              = var.region
  vpc_name            = var.vpc_name
  subnet_compute_cidr = var.subnet_compute_cidr
  vpc_connector_cidr  = var.vpc_connector_cidr
}
