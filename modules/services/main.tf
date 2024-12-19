terraform {
  required_providers {
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.25.0"
    }
    nginxproxymanager = {
        source  = "sander0542/nginxproxymanager"
        version = "~> 0.0.36"
    }
  }
}

provider "postgresql" {
  host            = "192.168.2.177"
  port            = 15432
  database        = "postgres"
  username        = "postgres"
  password        = "postgres"
  sslmode         = "disable"
  superuser       = true
  connect_timeout = 99999
}

provider "nginxproxymanager" {
  host     = "http://192.168.2.177:81"
  username = "juniodbl@dblsoft.xyz"
  password = "Ti#0ab1379"
}

resource "postgresql_database" "iam" {
  name                   = "iam"
  owner                  = "postgres"
  template               = "template0"
  lc_collate             = "C"
  connection_limit       = -1
  allow_connections      = true
  alter_object_ownership = true
  encoding               = "UTF8"
}

resource "nginxproxymanager_proxy_host" "database" {
  domain_names = ["db.dblsoft.lan"]

  forward_scheme = "http"
  forward_host   = "192.168.2.177"
  forward_port   = 5432

  caching_enabled         = false
  allow_websocket_upgrade = false
  block_exploits          = false

  access_list_id = 0 # Publicly Accessible

  certificate_id  = 0 # No Certificate
  ssl_forced      = false
  hsts_enabled    = false
  hsts_subdomains = false
  http2_support   = false

  advanced_config = ""
}

resource "nginxproxymanager_proxy_host" "proxy" {
  domain_names = ["proxy.dblsoft.lan"]

  forward_scheme = "http"
  forward_host   = "192.168.2.177"
  forward_port   = 81

  caching_enabled         = false
  allow_websocket_upgrade = false
  block_exploits          = false

  access_list_id = 0 # Publicly Accessible

  certificate_id  = 0 # No Certificate
  ssl_forced      = false
  hsts_enabled    = false
  hsts_subdomains = false
  http2_support   = false

  advanced_config = ""
}

resource "nginxproxymanager_proxy_host" "portainer" {
  domain_names = ["portainer.dblsoft.lan"]

  forward_scheme = "http"
  forward_host   = "192.168.2.177"
  forward_port   = 9000

  caching_enabled         = false
  allow_websocket_upgrade = false
  block_exploits          = false

  access_list_id = 0 # Publicly Accessible

  certificate_id  = 0 # No Certificate
  ssl_forced      = false
  hsts_enabled    = false
  hsts_subdomains = false
  http2_support   = false

  advanced_config = ""
}