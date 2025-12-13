#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

PACKAGES=(
  linux-lts                  # LTS Kernel
  base base-devel            # Base Packages
  grub                       # Boot
  openssh wget curl sudo git # Tools
  virtualbox-guest-utils-nox # Guest Additions
  # ansible   # Provisioner
  # go   # YaY Dependency
  # efibootmgr grub   # Boot
  # btrfs-progs e2fsprogs dosfstools   # File System
)

# Mounting
swapon /dev/sda1
mount /dev/sda2 /mnt

echo "disable-keyserver-lookup" >>~/.gnupg/gpg.conf

# Reinitialize the pacman keyring
pacman-key --init

# Populate the Arch Linux keyring
pacman-key --populate archlinux

# Refresh the keys
pacman-key --refresh-keys

pacman -Sy --noconfirm reflector

# Pacstrapping
pacstrap -K /mnt "${PACKAGES[@]}"

# Generating fstab
genfstab -U -p /mnt >>/mnt/etc/fstab

# Setup Pacman
arch-chroot /mnt /bin/bash -e <<EOF
sed -i "/^#.*CheckSpace/s/^#//" /etc/pacman.conf
sed -i "/^#.*Color/s/^#//" /etc/pacman.conf
sed -i "/^#.*ParallelDownloads = 5/s/^#//" /etc/pacman.conf
sed -i "/^#.*VerbosePkgLists/s/^#//" /etc/pacman.conf
# sed -i "/^#NoExtract/s/^#//" /etc/pacman.conf
# sed -i "/^NoExtract /s/$/ pacman-mirrorlist/" /etc/pacman.conf
EOF

# Setup Mirror List to Geo IP Mirrors
# arch-chroot /mnt /bin/bash -e <<EOF
# echo "# Ireland" > /etc/pacman.d/mirrorlist
# echo "Server = http://ftp.heanet.ie/mirrors/ftp.archlinux.org/$repo/os/$arch" >> /etc/pacman.d/mirrorlist
# echo "Server = https://ftp.heanet.ie/mirrors/ftp.archlinux.org/$repo/os/$arch" >> /etc/pacman.d/mirrorlist
# echo "" >> /etc/pacman.d/mirrorlist
# echo "# United Kingdom" >> /etc/pacman.d/mirrorlist
# echo "Server = http://archlinux.uk.mirror.allworldit.com/archlinux/$repo/os/$arch" >> /etc/pacman.d/mirrorlist
# echo "Server = https://archlinux.uk.mirror.allworldit.com/archlinux/$repo/os/$arch" >> /etc/pacman.d/mirrorlist
# EOF

arch-chroot /mnt /bin/bash -e <<EOF
# timedatectl set-ntp 1
# timedatectl set-timezone Europe/Dublin
# ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime
ln -sf /usr/share/zoneinfo/Europe/Dublin /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf

echo "vagrant" > /etc/hostname
echo "127.0.0.1   localhost" >> /etc/hosts
echo "::1         localhost" >> /etc/hosts
EOF

# Generating GRUB
arch-chroot /mnt /bin/bash -e <<EOF
mkinitcpio -p linux-lts
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
EOF

# Setup DHCP Network
arch-chroot /mnt /bin/bash -e <<EOF
echo "[Match]" > /etc/systemd/network/80-dhcp.network 
echo "Name=en*" >> /etc/systemd/network/80-dhcp.network
echo "Name=eth*" >> /etc/systemd/network/80-dhcp.network
echo "" >> /etc/systemd/network/80-dhcp.network
echo "[Network]" >> /etc/systemd/network/80-dhcp.network
echo "DHCP=yes" >> /etc/systemd/network/80-dhcp.network
EOF

# Setup Users
arch-chroot /mnt /bin/bash -e <<EOF
useradd -m -U vagrant
echo "vagrant:vagrant" | chpasswd
echo "root:root" | chpasswd
EOF

# Setup Sudoers
arch-chroot /mnt /bin/bash -e <<EOF
echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers
echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
EOF

# Install Vagrant SSH Key
arch-chroot /mnt /bin/bash -e <<EOF
install --directory --owner=vagrant --group=vagrant --mode=0700 /home/vagrant/.ssh
curl --output /home/vagrant/.ssh/authorized_keys --location https://github.com/hashicorp/vagrant/raw/main/keys/vagrant.pub
# WARNING: Please only update the hash if you are 100% sure it was intentionally updated by upstream.
sha256sum -c <<< "55009a554ba2d409565018498f1ad5946854bf90fa8d13fd3fdc2faa102c1122 /home/vagrant/.ssh/authorized_keys"
chown vagrant:vagrant /home/vagrant/.ssh/authorized_keys
chmod 0600 /home/vagrant/.ssh/authorized_keys
EOF

# Enabling Important Services
arch-chroot /mnt /bin/bash -e <<EOF
source /etc/profile
systemctl daemon-reload
systemctl enable sshd
systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable systemd-timesyncd
systemctl enable systemd-time-wait-sync
systemctl enable vboxservice.service
EOF

# Setup resolvconf
arch-chroot /mnt /bin/bash -e <<EOF
echo "nameserver 1.1.1.1" > /etc/resolv.conf
EOF

# Setup YaY
arch-chroot /mnt /bin/bash -e <<EOF
su - vagrant
git clone https://aur.archlinux.org/yay.git /tmp/yay
cd /tmp/yay
makepkg -fsri --noconfirm
EOF
