# Arch Linux Development Box

> A minimalistic Arch Linux-based development Vagrant Box and Template

This repository contains the build system for a base (Arch Linux)[https://archlinux.org/] - based development virtual machine image.

This VM can either be used directly or can be customized to suit your needs.

## Using the bare VM

To run the VM, you'll need **[Vagrant](https://www.vagrantup.com/)** and **[VirtualBox](https://www.virtualbox.org/)**.

Run the following command to create a new Vagrantfile:

```bash
$ vagrant init thinasc/arch64
```

If you're new to Vagrant, check out the [Vagrant documentation](https://developer.hashicorp.com/vagrant).

## Customizing

If you wish to build a custom base box based on this one, read the [documentation on customization](customization.md).

## Building

For building your own image locally, enter the following command:

```bash
$ ./build.sh
```

**[Packer](https://www.packer.io/)** is required to build an image in addition to Vagrant and VirtualBox.

## Configuration

This base box is designed to be a good starting point for an Arch Linux-based development environment.

### Configuration

- 64 GB primary disk
  - Dynamically allocated
  - 16 GB SWAP
  - 47,5 GB ROOT (ext4)
- UTC timezone, `en_US.UTF-8` locale, `us` keymap
- NTP-synced time
- Network management using systemd
- Default hostname: `vagrant`
- Optimized boot process
  - Minimal Initrd
  - No bootloader (EFI booting)
- Regular mirrorlist updates using Reflector

### Installed packages

- `linux-lts`
- `base` (group), `base-devel` (group)
- `e2fsprogs`, `dosfstools`
- `efibootmgr`
- `openssh`
- `systemd-resolvconf`
- `reflector`
- `virtualbox-guest-utils-nox`
- `neovim`
- `wget`, `curl`
- `sudo`
- `git`
- `man-db`, `man-pages`, `texinfo`
- `fish`
- `yay`

## Legal

This project's configuration files and installation scripts are licensed under the MIT License.

This project is not an official project of the Arch Linux distribution. The Arch Linux name and logo are recognized trademarks. Some rights reserved.
