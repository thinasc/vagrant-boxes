source "virtualbox-iso" "arch64" {
  guest_os_type = "ArchLinux_64"
  vm_name       = "packer-virtualbox"

  iso_url       = "https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso"
  iso_checksum  = "file:https://geo.mirror.pkgbuild.com/iso/latest/sha256sums.txt"

  cpus    = var.build_cpus
  memory  = var.build_memory
  headless = true

  # Graphics Controller (modern and compatible)
  gfx_controller = "vmsvga"
  gfx_vram_size  = 128

  # Disk
  disk_size               = 102400
  hard_drive_interface    = "pcie"
  hard_drive_nonrotational = true
  hard_drive_discard       = true
  iso_interface           = "sata"

  guest_additions_mode = "disable"
  boot_wait            = "${var.boot_wait_time}s"

  boot_command = [
    "echo 'root:root' | chpasswd<enter>"
  ]

  ssh_username = "root"
  ssh_password = "root"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"

  vboxmanage = [
    # VM Core Features
    ["modifyvm", "{{.Name}}", "--acpi=on"],
    ["modifyvm", "{{.Name}}", "--ioapic=on"],
    ["modifyvm", "{{.Name}}", "--pae=on"],
    ["modifyvm", "{{.Name}}", "--long-mode=on"],
    ["modifyvm", "{{.Name}}", "--firmware=efi"],
    ["modifyvm", "{{.Name}}", "--paravirtprovider=kvm"],
    ["modifyvm", "{{.Name}}", "--nested-paging=on"],
    ["modifyvm", "{{.Name}}", "--largepages=on"],

    # Remove IDE Controller
    ["storagectl", "{{.Name}}", "--name", "IDE Controller", "--remove"],

    # Add NVMe Controller for Virtual Disk
    ["storagectl", "{{.Name}}", "--name", "NVMe Controller", "--hostiocache=on", "--portcount=1"]
  ]

  vboxmanage_post = [
    # Remove SATA Controller
    ["storagectl", "{{.Name}}", "--name", "SATA Controller", "--remove"],

    # Adjust Final CPU & Memory
    ["modifyvm", "{{.Name}}", "--cpus=${var.image_cpus}"],
    ["modifyvm", "{{.Name}}", "--memory=${var.image_memory}"]
  ]
}
