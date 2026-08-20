variable "ssh_public_key" {
  description = "Existing SSH public key for server access"
  type        = string
}

variable "ssh_allowed_ipv4" {
  description = "IPv4 CIDR allowed to connect over SSH"
  type        = string
  default     = "0.0.0.0/0"
}

variable "server_type" {
  description = "Hetzner Cloud server type"
  type        = string
  default     = "cx23"
}

variable "location" {
  description = "Hetzner Cloud location"
  type        = string
  default     = "nbg1"
}

variable "image" {
  description = "Server operating system"
  type        = string
  default     = "ubuntu-24.04"
}
