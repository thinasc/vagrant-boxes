#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

# Partitioning
parted -s /dev/sda mklabel msdos
parted /dev/sda mkpart primary 1MiB 4GiB
parted /dev/sda mkpart primary 4GiB 100%

mkswap /dev/sda1
mkfs.ext4 /dev/sda2
