variable "vm_ip" {
  description = "Public IP address of the Docker host"
  type        = string
}

variable "ssh_user" {
  description = "SSH user allowed to access the remote Docker socket"
  type        = string
  default     = "student"
}

variable "ssh_private_key_path" {
  description = "Path to the private SSH key used for the Docker connection"
  type        = string
  default     = "~/.ssh/devops_hw_ed25519"
}

variable "nginx_external_port" {
  description = "Non-standard host port published for Nginx"
  type        = number
  default     = 8080

  validation {
    condition     = var.nginx_external_port > 1024 && var.nginx_external_port < 65536
    error_message = "The Nginx port must be a non-privileged TCP port between 1025 and 65535."
  }
}
