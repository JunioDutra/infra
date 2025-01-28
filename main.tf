module "docker" {
  source = "./modules/docker"
}

module "docker-opi4lts" {
  source = "./modules/docker-opi4lts"
}

module "services" {
  source = "./modules/services"
}
