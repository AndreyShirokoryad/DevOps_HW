terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "registry.opentofu.org/kreuzwerker/docker"
      version = "4.6.0"
    }
  }
}

provider "docker" {
  host = "ssh://${var.ssh_user}@${var.vm_ip}:22"

  ssh_opts = [
    "-i", pathexpand(var.ssh_private_key_path),
    "-o", "IdentitiesOnly=yes",
  ]
}

resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = false
}

resource "docker_network" "nginx" {
  name   = "terraform_nginx_network"
  driver = "bridge"
}

resource "docker_volume" "nginx" {
  name = "terraform_nginx_data"
}

resource "docker_container" "nginx" {
  name    = "terraform-nginx"
  image   = docker_image.nginx.image_id
  restart = "unless-stopped"

  networks_advanced {
    name = docker_network.nginx.name
  }

  ports {
    internal = 80
    external = var.nginx_external_port
    protocol = "tcp"
  }

  volumes {
    volume_name    = docker_volume.nginx.name
    container_path = "/usr/share/nginx/html"
  }

  upload {
    file    = "/usr/share/nginx/html/index.html"
    content = <<-HTML
      <!doctype html>
      <html lang="en">
        <head><meta charset="utf-8"><title>Terraform Nginx</title></head>
        <body><h1>Nginx is managed by Terraform</h1></body>
      </html>
    HTML
  }

  healthcheck {
    test         = ["CMD-SHELL", "wget -qO- http://127.0.0.1/ >/dev/null || exit 1"]
    interval     = "10s"
    timeout      = "3s"
    retries      = 3
    start_period = "5s"
  }

  wait         = true
  wait_timeout = 60
}
