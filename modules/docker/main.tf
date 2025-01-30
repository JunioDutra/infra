terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "tcp://192.168.2.177:2375"
}

resource "docker_image" "cloudflared" {
  name         = "cloudflare/cloudflared:latest"
  keep_locally = true
}

resource "docker_image" "nginx_proxy_manager" {
  name         = "jc21/nginx-proxy-manager:latest"
  keep_locally = true
}

resource "docker_image" "postgres" {
  name         = "postgres:latest"
  keep_locally = false
}

resource "docker_image" "homepage" {
  name         = "ghcr.io/gethomepage/homepage:latest"
  keep_locally = false
}

resource "docker_image" "jellyfin" {
  name         = "jellyfin/jellyfin"
  keep_locally = false
}


resource "docker_volume" "nginx_proxy_manager_data" {
  name = "nginx-proxy-manager-data"
}

resource "docker_volume" "nginx_proxy_manager_letsencrypt" {
  name = "nginx-proxy-manager-letsencrypt"
}

resource "docker_volume" "postgres" {
  name = "postgres"
}

resource "docker_volume" "jellyfin_cache" {
  name = "jellyfin-cache"
}

resource "docker_volume" "jellyfin_config" {
  name = "jellyfin-config"
}

resource "docker_container" "cloudflared" {
  image = docker_image.cloudflared.image_id
  name  = "cloudflared"

  command = [
    "tunnel",
    "--no-autoupdate",
    "run",
    "--token",
    "eyJhIjoiN2YwYjViYjc3OGNiNWJiNGE1NTMzMGQ5MmMwODExNWEiLCJ0IjoiYTZmNTFhOTgtN2RmOS00NDA2LWIxM2UtZWFkNzJiMmMzZGFjIiwicyI6IlpEQTVaR0kyWVdRdE56bGlOaTAwTkRjMExUZ3lNekF0WkdObE9HUmtaR0kzWkdJdyJ9"
  ]

  restart = "unless-stopped"

  lifecycle {
    ignore_changes = [
      command,
      entrypoint,
      hostname,
      ipc_mode,
      log_driver,
      network_mode,
      runtime,
      security_opts,
      shm_size,
      stop_signal,
      stop_timeout,
    ]
  }
}

resource "docker_container" "nginx_proxy_manager" {
  image = docker_image.nginx_proxy_manager.image_id
  name  = "nginx-proxy-manager"

  ports {
    internal = 80
    external = 80
  }

  ports {
    internal = 81
    external = 81
  }

  ports {
    internal = 443
    external = 443
  }

  volumes {
    volume_name    = docker_volume.nginx_proxy_manager_data.name
    container_path = "/data"
  }

  volumes {
    volume_name    = docker_volume.nginx_proxy_manager_letsencrypt.name
    container_path = "/etc/letsencrypt"
  }

  restart = "unless-stopped"

  lifecycle {
    ignore_changes = [
      command,
      entrypoint,
      hostname,
      ipc_mode,
      log_driver,
      network_mode,
      runtime,
      security_opts,
      shm_size,
      stop_signal,
      stop_timeout,
    ]
  }
}

resource "docker_container" "postgres" {
  image = docker_image.postgres.image_id
  name  = "postgres"

  env = [
    "POSTGRES_USER=postgres",
    "POSTGRES_PASSWORD=postgres",
    "POSTGRES_DB=postgres",
  ]

  volumes {
    volume_name    = docker_volume.postgres.name
    container_path = "/var/lib/postgresql/data"
  }

  restart = "unless-stopped"

  ports {
    internal = 5432
    external = 15432
  }

  lifecycle {
    ignore_changes = [
      command,
      entrypoint,
      hostname,
      ipc_mode,
      log_driver,
      network_mode,
      runtime,
      security_opts,
      shm_size,
      stop_signal,
      stop_timeout,
    ]
  }
}

resource "docker_container" "homepage" {
  image = docker_image.homepage.image_id
  name  = "homepage"

  env = [
  ]

  volumes {
    container_path = "/app/config"
    host_path      = "/home/srv/docker-volumes/homepage/config"
  }

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
  }

  restart = "unless-stopped"
  tty = true
  stdin_open = true

  ports {
    internal = 3000
    external = 3000
  }

  lifecycle {
    ignore_changes = [
      command,
      entrypoint,
      hostname,
      ipc_mode,
      log_driver,
      network_mode,
      runtime,
      security_opts,
      shm_size,
      stop_signal,
      stop_timeout,
    ]
  }
}

resource "docker_container" "jellyfin" {
  image = docker_image.jellyfin.image_id
  name  = "jellyfin"

  env = [
  ]

  volumes {
    volume_name    = docker_volume.jellyfin_cache.name
    container_path = "/cache"
  }

  volumes {
    volume_name    = docker_volume.jellyfin_config.name
    container_path = "/config"
  }
  volumes { 
    container_path = "/media"
    host_path      = "/home/srv/docker-volumes/jellyfin/media"
  }

  user = "1001:1001"

  restart = "unless-stopped"
  network_mode = "host"

  tty = true
  stdin_open = true
   
  ports {
    internal = 3000
    external = 3000
  }

  lifecycle {
    ignore_changes = [
      command,
      entrypoint,
      hostname,
      ipc_mode,
      log_driver,
      network_mode,
      runtime,
      security_opts,
      shm_size,
      stop_signal,
      stop_timeout,
    ]
  }
}

resource "docker_image" "open_webui" {
  name         = "ghcr.io/open-webui/open-webui:main"
  keep_locally = false
}

resource "docker_volume" "open_webui" {
  name = "open-webui"
}

resource "docker_container" "open_webui" {
  image = docker_image.open_webui.image_id
  name  = "open-webui"

  env = [
    "OLLAMA_BASE_URL=http://ubuntu-ai:11434/"
  ]

  volumes {
    volume_name    = docker_volume.open_webui.name
    container_path = "/app/backend/data"
  }

  restart = "unless-stopped"

  ports {
    internal = 8080
    external = 13099
  }

  lifecycle {
    ignore_changes = [
      command,
      entrypoint,
      hostname,
      ipc_mode,
      log_driver,
      network_mode,
      runtime,
      security_opts,
      shm_size,
      stop_signal,
      stop_timeout,
    ]
  }
}