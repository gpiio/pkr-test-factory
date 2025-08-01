#cloud-config
autoinstall:
  version: 1
  interactive-sections: []
  network:
    network:
      version: 2
      ethernets:
        ens18:
          dhcp4: true
          dhcp4-overrides:
            use-dns: false
            use-routes: true
          nameservers:
            addresses: ${vm_dns_addresses}
  apt:
    geoip: false
    preserve_sources_list: false
    primary:
      - arches: [amd64]
        uri: https://us.archive.ubuntu.com/ubuntu
      - arches: [default]
        uri: https://ports.ubuntu.com/ubuntu-ports
  locale: en_US
  keyboard:
    layout: us
  storage:
    layout:
      name: direct
  identity:
    hostname: base-ubuntu-tpl
    username: ${username}
    password: ${password}
  ssh:
    install-server: true
    allow-pw: true
    disable_root: false
    ssh_pwauth: true
  packages:
    - openssh-server
    - curl
    - wget
    - vim
    - htop
    - unzip
    - qemu-guest-agent
  late-commands:
    - echo '${username} ALL=(ALL) NOPASSWD:ALL' > /target/etc/sudoers.d/${username}
    - curtin in-target --target=/target -- apt-get update
    - curtin in-target --target=/target -- systemctl enable ssh
    - curtin in-target --target=/target -- systemctl enable qemu-guest-agent
    - curtin in-target --target=/target -- sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
  shutdown: reboot
