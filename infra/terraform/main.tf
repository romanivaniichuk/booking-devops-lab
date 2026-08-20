resource "hcloud_firewall" "booking" {
  name = "booking-devops-lab"

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "22"
    source_ips  = [var.ssh_allowed_ipv4]
    description = "SSH"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "80"
    source_ips  = ["0.0.0.0/0", "::/0"]
    description = "HTTP"
  }

  rule {
    direction   = "in"
    protocol    = "tcp"
    port        = "443"
    source_ips  = ["0.0.0.0/0", "::/0"]
    description = "HTTPS"
  }
}

resource "hcloud_ssh_key" "booking" {
  name       = "booking-devops-lab"
  public_key = var.ssh_public_key
}

resource "hcloud_server" "booking" {
  name        = "booking-devops-lab"
  image       = var.image
  server_type = var.server_type
  location    = var.location

  ssh_keys     = [hcloud_ssh_key.booking.id]
  firewall_ids = [hcloud_firewall.booking.id]

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  user_data = <<-EOF
    #cloud-config
    package_update: true

    packages:
      - curl

    runcmd:
      - 'curl -sfL https://get.k3s.io | sh -'
  EOF

  labels = {
    project    = "booking-devops-lab"
    managed_by = "terraform"
  }
}
