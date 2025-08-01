# Packer Templates for Proxmox

This repository contains Packer templates for building VM templates on Proxmox VE.

## Templates

### base-ubuntu
Base Ubuntu 22.04 template with minimal configuration.

**Template ID:** 4000  
**Build time:** ~15-20 minutes

## Usage

```bash
# Validate template
packer validate -var-file=variables.pkrvars.hcl base-ubuntu.pkr.hcl

# Build template
packer build -var-file=variables.pkrvars.hcl base-ubuntu.pkr.hcl
```

## Configuration

Copy `variables.pkrvars.hcl` and update with your Proxmox credentials:

```hcl
proxmox_api_url = "https://your-proxmox:8006/api2/json"
proxmox_api_token_id = "your-token-id"
proxmox_api_token_secret = "your-token-secret"
```
