# Proxmox Configuration (API credentials set via environment variables)
proxmox_node = "pve"
proxmox_storage_pool = "local"
proxmox_storage_pool_type = "directory"

# Ubuntu ISO Configuration
ubuntu_iso_url = "https://releases.ubuntu.com/22.04/ubuntu-22.04.5-live-server-amd64.iso"
ubuntu_iso_checksum = "9bc6028870aef3f74f4e16b900008179e78b130e6b0b9a140635434a46aa98b0"

# VM Configuration (credentials set via environment variables)
vm_dns_addresses = ["8.8.8.8", "8.8.4.4"]

# SSH Keys (add your public keys here)
ssh_public_keys = []