output "server_public_ip" {
  description = "Public IPv4 address of the k3s server"
  value       = hcloud_server.booking.ipv4_address
}
