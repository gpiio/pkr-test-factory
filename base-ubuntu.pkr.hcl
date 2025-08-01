packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}

# Variable definitions
variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_token_id" {
  type = string
}

variable "proxmox_api_token_secret" {
  type      = string
  sensitive = true
}

variable "proxmox_node" {
  type    = string
  default = "pve"
}

variable "proxmox_storage_pool" {
  type    = string
  default = "local"
}

variable "ubuntu_iso_url" {
  type = string
}

variable "ubuntu_iso_checksum" {
  type = string
}

variable "vm_dns_addresses" {
  type      = list(string)
  sensitive = true
}

variable "vm_ssh_username" {
  type      = string
  sensitive = true
}

variable "vm_ssh_password" {
  type      = string
  sensitive = true
}

variable "ssh_public_keys" {
  type        = list(string)
  description = "List of SSH public keys to add to the template"
  default     = []
}

locals {
  buildtime = formatdate("YYYY-MM-DD", timestamp())
  password_hash = bcrypt(var.vm_ssh_password)
  data_source_content = {
    "/meta-data" = file("${abspath(path.root)}/data/meta-data")
    "/user-data" = templatefile("${abspath(path.root)}/data/user-data.pkrtpl.hcl", {
      vm_dns_addresses = jsonencode(var.vm_dns_addresses)
      username = var.vm_ssh_username
      password = local.password_hash
      ssh_public_keys = var.ssh_public_keys
    })
  }
}

source "proxmox-iso" "base-ubuntu" {
  # Proxmox connection
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_token_id
  token                    = var.proxmox_api_token_secret
  insecure_skip_tls_verify = true
  node                     = var.proxmox_node

  # VM General Settings
  vm_name              = "packer-base-ubuntu"
  vm_id                = 4000
  template_description = "Base Ubuntu 22.04 LTS Server Template - Built with Packer"
  template_name        = "base-ubuntu-22-04"

  # VM OS Settings
  boot_iso {
    iso_file = "local:iso/ubuntu-22.04.5-live-server-amd64.iso"
  }

  # VM System Settings  
  qemu_agent = true

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-pci"
  disks {
    disk_size    = "20G"
    format       = "raw"
    storage_pool = "local-lvm"
    type         = "virtio"
  }

  # VM CPU Settings
  cores = "2"

  # VM Memory Settings
  memory = "2048"

  # VM Network Settings
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false"
  }

  # VM Cloud-Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  # Boot Commands
  boot_command = [
    "e<wait>",
    "<down><down><down><end>",
    " autoinstall ds=nocloud",
    "<f10>"
  ]
  boot      = "c"
  boot_wait = "10s"

  # CD content with autoinstall config  
  additional_iso_files {
    cd_content       = local.data_source_content
    cd_label         = "cidata"
    iso_storage_pool = "local"
    unmount          = true
  }

  # Communicator Settings
  communicator           = "ssh"
  ssh_username           = var.vm_ssh_username
  ssh_password           = var.vm_ssh_password
  ssh_timeout            = "30m"
  ssh_handshake_attempts = 20
  ssh_wait_timeout       = "30m"
  
  # Task timeout settings
  task_timeout = "40m"
}

build {
  sources = [
    "source.proxmox-iso.base-ubuntu"
  ]

  provisioner "ansible" {
    playbook_file = "${path.cwd}/ansible/base.yml"
    roles_path    = "${path.cwd}/ansible/roles"
    user          = var.vm_ssh_username
    extra_arguments = [
      "-e", "display_skipped_hosts=false",
      "-e", "ansible_ssh_user=${var.vm_ssh_username}",
      "-e", "ansible_ssh_pass=${var.vm_ssh_password}"
    ]
  }
}
