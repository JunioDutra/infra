module "docker" {
  source = "./modules/docker"
}

module "services" {
  source = "./modules/services"
}
