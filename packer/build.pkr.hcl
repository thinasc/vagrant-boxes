build {
  sources = ["sources.virtualbox-iso.arch64"]

  provisioner "shell" {
    scripts = [
      "installation/setup_disk.sh",
      "installation/bootstrap.sh",
      "provision/scripts/install_progs.sh"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      architecture = "amd64"
      output = "output/${var.build_name}_${var.build_version}_{{ .Provider }}.box"
    }
  }
}
