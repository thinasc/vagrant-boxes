source "virtualbox-iso" "arch64" {
  guest_os_type = "ArchLinux_64"
  vm_name = "packer-virtualbox"

  iso_url = "https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso"
  iso_checksum = "file:https://geo.mirror.pkgbuild.com/iso/latest/sha256sums.txt"
 
  cpus = var.build_cpus
  memory = var.build_memory

  headless = true

  # Graphics Controller
  gfx_controller = "vboxvga"
  gfx_vram_size = 128

  disk_size = 102400
  hard_drive_interface = "sata"
  hard_drive_nonrotational = true
  hard_drive_discard = true
  iso_interface = "sata"

  guest_additions_mode = "disable"

  boot_wait = "${var.boot_wait_time}s"
  boot_command = [
    "echo 'root:root' | chpasswd<enter>"
  ]

  ssh_username = "root"
  ssh_password = "root"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--acpi=on"],
    ["modifyvm", "{{.Name}}", "--apic=on"],
    ["modifyvm", "{{.Name}}", "--x2apic=on"],
    ["modifyvm", "{{.Name}}", "--ioapic=on"],
    ["modifyvm", "{{.Name}}", "--bios-apic=apic"],
    ["modifyvm", "{{.Name}}", "--paravirt-provider=default"],
    ["modifyvm", "{{.Name}}", "--pae=on"],
    ["modifyvm", "{{.Name}}", "--long-mode=on"],
    ["modifyvm", "{{.Name}}", "--nested-paging=on"],
    ["modifyvm", "{{.Name}}", "--large-pages=on"],

    ["storagectl", "{{.Name}}", "--name", "IDE Controller", "--remove"],
    ["storagectl", "{{.Name}}", "--name", "SATA Controller", "--hostiocache=on"],
  ]

  vboxmanage_post = [
    ["storagectl", "{{.Name}}", "--name", "SATA Controller", "--portcount=1"],

    ["modifyvm", "{{.Name}}", "--cpus=${var.image_cpus}"],
    ["modifyvm", "{{.Name}}", "--memory=${var.image_memory}"],
  ]
}
