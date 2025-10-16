terraform {
  required_version = ">= 1.7.0" # OpenTofu 1.7+ for encryption
  required_providers {
    upcloud = {
      source  = "UpCloudLtd/upcloud"
      version = "~> 5.0"
    }
  }

}

provider "upcloud" {
  # Uses UPCLOUD_USERNAME and UPCLOUD_PASSWORD from environment
}

resource "upcloud_server" "my_server" {
  hostname = var.hostname
  zone     = var.zone
  plan     = var.vm_type

  template {
    storage = "Ubuntu Server 22.04 LTS (Jammy Jellyfish)"
    size    = var.storage_size
  }

  # Required by your policy pack
  labels = var.labels

  network_interface {
    type = "public"
  }

  # Required for cloud-init images
  metadata  = true
  user_data = <<-EOT
    #cloud-config
    runcmd:
      - [ bash, -lc, "echo upcloud ok" ]
  EOT

}
