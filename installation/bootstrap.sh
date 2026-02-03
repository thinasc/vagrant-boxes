#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

################################
# Variables
################################
DISK=/dev/nvme0n1
EFI_PARTITION="${DISK}p1"
BTRFS_PARTITION="${DISK}p2"

PACKAGES=(
  linux-lts linux-firmware   # LTS Kernel
  base base-devel            # Base Packages
  btrfs-progs                # File System
  efibootmgr grub            # Boot
  zram-generator             # Swap
  openssh wget curl sudo git # Tools
  virtualbox-guest-utils-nox # Guest Additions
)

################################
# Mount & Btrfs Setup
################################
mkdir -p /mnt
mount -t btrfs "$BTRFS_PARTITION" /mnt

for sub in @ @home @var; do
  btrfs subvolume create "/mnt/$sub" || true
done

umount /mnt

# Mount root subvolume
mount -t btrfs -o noatime,compress=zstd,space_cache=v2,subvol=@ "$BTRFS_PARTITION" /mnt

# Create directories for other subvolumes
mkdir -p /mnt/{boot,home,var}

# Mount subvolumes
mount -t btrfs -o noatime,compress=zstd,space_cache=v2,subvol=@home "$BTRFS_PARTITION" /mnt/home
mount -t btrfs -o noatime,compress=zstd,space_cache=v2,subvol=@var "$BTRFS_PARTITION" /mnt/var

################################
# Mount EFI
################################
mkdir -p /mnt/boot
mount -t vfat "$EFI_PARTITION" /mnt/boot

################################
# Pacstrap
################################
pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys

pacstrap -K /mnt "${PACKAGES[@]}"
genfstab -U /mnt >>/mnt/etc/fstab

################################
# Base System Configuration
################################
arch-chroot /mnt /bin/bash <<EOF
set -e

# Time & Locale
ln -sf /usr/share/zoneinfo/Europe/Dublin /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

# Host
echo "vagrant" > /etc/hostname
cat <<HOSTS > /etc/hosts
127.0.0.1 localhost
::1       localhost
HOSTS

# Pacman UX
sed -i "/^#.*CheckSpace/s/^#//" /etc/pacman.conf
sed -i 's/^#Color/Color/' /etc/pacman.conf
sed -i 's/^#ParallelDownloads.*/ParallelDownloads = 5/' /etc/pacman.conf
sed -i "/^#.*VerbosePkgLists/s/^#//" /etc/pacman.conf

# mkinitcpio
sed -i 's/^MODULES=.*/MODULES=(btrfs)/' /etc/mkinitcpio.conf
mkinitcpio -P
EOF

################################
# Bootloader (UEFI / GRUB)
################################
arch-chroot /mnt grub-install \
  --target=x86_64-efi \
  --efi-directory=/boot \
  --bootloader-id=GRUB \
  --removable

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg

################################
# Network (systemd-networkd)
################################
cat >/mnt/etc/systemd/network/80-dhcp.network <<'EOF'
[Match]
Name=en*
Name=eth*

[Network]
DHCP=yes
EOF

################################
# Users & sudo
################################
arch-chroot /mnt /bin/bash <<'EOF'
useradd -m -U vagrant
echo "vagrant:vagrant" | chpasswd
echo "root:root" | chpasswd

echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant
EOF

################################
# Vagrant SSH Key
################################
arch-chroot /mnt /bin/bash <<'EOF'
install -d -m 700 -o vagrant -g vagrant /home/vagrant/.ssh
curl -fsSL https://github.com/hashicorp/vagrant/raw/main/keys/vagrant.pub \
  -o /home/vagrant/.ssh/authorized_keys
# WARNING: Please only update the hash if you are 100% sure it was intentionally updated by upstream.
sha256sum -c <<< "55009a554ba2d409565018498f1ad5946854bf90fa8d13fd3fdc2faa102c1122 /home/vagrant/.ssh/authorized_keys"
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
chmod 600 /home/vagrant/.ssh/authorized_keys
EOF

################################
# Enable Services
################################
arch-chroot /mnt systemctl enable \
  sshd \
  systemd-networkd \
  systemd-resolved \
  systemd-timesyncd \
  vboxservice.service

################################
# ZRAM (4G, Clean & Official)
################################
cat >/mnt/etc/systemd/zram-generator.conf <<'EOF'
[zram0]
zram-size = min(ram / 4, 2048)
compression-algorithm = zstd
swap-priority = 100
EOF

echo "vm.swappiness=10" >/mnt/etc/sysctl.d/99-swappiness.conf

################################
# Install YaY for vagrant user
################################
arch-chroot /mnt /bin/bash -c '
set -e
if ! command -v yay &>/dev/null; then
    sudo -u vagrant bash -c "
        cd /tmp
        rm -rf yay
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -fsri --noconfirm
    "
fi
'
