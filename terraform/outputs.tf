output "nginx_url" {
  description = "URL of the Nginx container managed by Terraform"
  value       = "http://${var.vm_ip}:${var.nginx_external_port}"
}

output "verification_command" {
  description = "Command that verifies the Nginx HTTP response"
  value       = "curl -i http://${var.vm_ip}:${var.nginx_external_port}"
}
