terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "tcp://192.168.2.174:2375"
}

resource "docker_image" "azpagent" {
  name         = "azp-agent:linux"
  keep_locally = true
}

resource "docker_container" "azpagent" {
  image = docker_image.azpagent.image_id
  name  = "azpagent-arm-2"

  env = [
     "AZP_URL=https://dbl.visualstudio.com/",
     "AZP_TOKEN=7wEO8vIfYGgtIgaeC50Xsr3dvr7MvVL7yNX54YB1aPphsOJkrnwWJQQJ99BAACAAAAAAAAAAAAASAZDOvcP8",
     "AZP_POOL=Default",
     "AZP_AGENT_NAME=azpagent",
  ]

  restart = "unless-stopped"

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
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

  tty = true
  stdin_open = true
}
