terraform {
  required_version = "~> 1.15.0"

  cloud {
    organization = "roman-booking-devops"

    workspaces {
      name = "booking-devops-lab-prod"
    }
  }

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.68.0"
    }
  }
}

provider "hcloud" {}
