# Arch Linux Development Box

> An automated [Arch Linux](https://archlinux.org/)-based Vagrant box for development

This repository contains the full build system for an Arch Linux development VM. It uses **Packer**
to provision a VirtualBox image from scratch, package it as a `.box` file, and deploy it to a
self-hosted registry.

## Using the box

You'll need **[Vagrant](https://www.vagrantup.com/)** and
**[VirtualBox](https://www.virtualbox.org/)**.

The box is hosted on a self-hosted [Forgejo](https://forgejo.org/) package registry. Add it to a new
project:

```bash
vagrant init thinasc/arch64 --box-version "$(date +%Y.%m)" \
  --box-url https://forgejo.homelab.thinasc.com/api/packages/thinasc/vagrant
```

If you're new to Vagrant, check out the
[Vagrant documentation](https://developer.hashicorp.com/vagrant).

## Building

You'll need **[Packer](https://www.packer.io/)**, **VirtualBox**, and
**[Task](https://taskfile.dev/)**.

```bash
task build
```

This will:

1. Clean previous build artifacts
2. Download Packer plugins (`packer init`)
3. Build the VM from the latest Arch Linux ISO
4. Package it as `dist/arch64_<YYYY.MM>_virtualbox.box`

## Deploying

To upload the built box to the Forgejo registry:

```bash
task deploy
```

Requires a `FORGEJO_TOKEN` environment variable (set via `.envrc`, which is gitignored).

## Configuration

### System

- **Disk:** 100 GB NVMe (dynamically allocated, TRIM enabled)
  - 512 MB EFI partition (FAT32)
  - Remaining space formatted as **btrfs** with subvolumes: `@` (root), `@home`, `@var`
    - Mount options: `noatime,compress=zstd,space_cache=v2`
- **Swap:** ZRAM (`min(RAM/4, 4096 MB)`, `zstd` compression) — no swap partition
- **Firmware:** UEFI, bootloader: GRUB (`x86_64-efi`, `--removable`)
- **Timezone:** `Europe/Dublin`, locale: `en_US.UTF-8`, keymap: `us`
- **Hostname:** `vagrant`
- **Network:** `systemd-networkd` with DHCP on `en*`/`eth*`; IPv6 disabled
- **Time Sync:** `systemd-timesyncd`

### Installed Packages

**Base:**

- `linux-lts`, `linux-firmware`
- `base`, `base-devel`
- `btrfs-progs`
- `efibootmgr`, `grub`
- `zram-generator`
- `openssh`, `wget`, `curl`, `sudo`, `git`
- `virtualbox-guest-utils-nox`

**Development Tools:**

- `ansible`, `python-requests`
- `docker` (service enabled, `vagrant` user added to `docker` group)
- `neovim`, `tree-sitter`, `unzip`
- `fish` (default shell)

**Shell & Terminal:**

- `starship`, `tmux`, `tmuxp`, `direnv`, `mise`, `stow`
- `lazygit`, `git-delta`
- `fzf`, `fd`, `ripgrep`
- `zoxide`, `eza`, `bat`, `tree`, `ncdu`, `jq`
- `htop`, `fastfetch`
- `bc`, `lsof`

**AUR (via `yay`):**

- `opencode-bin`
- `tmux-plugin-manager`
- `tree-sitter-cli`

### Fish Shell

Fish is configured at `/home/vagrant/.config/fish/config.fish` with:

- Hooks for `mise`, `direnv`, `starship`, `zoxide`
- `TERM=xterm-256color`, `EDITOR=nvim`, `GIT_EDITOR=$EDITOR`

### Vagrant User

- Username: `vagrant`, password: `vagrant`
- Root password: `root`
- Full passwordless sudo
- Vagrant insecure public key pre-installed

## CI/CD

The `.forgejo/workflows/deploy.yml` workflow can be triggered manually. It runs on a self-hosted
runner, installs all dependencies (VirtualBox 7.1, Packer, Vagrant, Task), then runs
`task build && task deploy`.
