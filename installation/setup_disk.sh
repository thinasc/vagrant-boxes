#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

# Target Disk (use NVMe)
DISK=/dev/nvme0n1

# Partitioning: create a GPT layout with an EFI System Partition and a btrfs root
# - EFI partition: 1MiB..513MiB (~512MiB) (FAT32)
# - Root partition: 513MiB..end (btrfs)
# Note: this layout does not create a swap partition
parted -s "$DISK" mklabel gpt
parted -s "$DISK" mkpart ESP fat32 1MiB 513MiB # EFI ~512MiB
parted "$DISK" set 1 boot on
parted -s "$DISK" mkpart primary btrfs 513MiB 100%

# Format EFI partition as FAT32
mkfs.fat -F32 "${DISK}p1"

# Format root partition as btrfs
mkfs.btrfs -f "${DISK}p2"
