#!/usr/bin/env bash
# -*- coding: utf-8 -*-

set -e

# Config
arch-chroot /mnt /bin/bash -e <<EOF
echo "Increase Watches"
echo fs.inotify.max_user_watches=524288 | tee /etc/sysctl.d/40-max-user-watches.conf

echo "Disable IPv6"
echo net.ipv6.conf.all.disable_ipv6 | tee /etc/sysctl.d/99-disable-ipv6.conf
echo net.ipv6.conf.default.disable_ipv6 | tee -a /etc/sysctl.d/99-disable-ipv6.conf

sysctl --system
EOF

# Setup with Pacman
arch-chroot /mnt /bin/bash -e <<EOF
echo "Installing Ansible"
yes | pacman -S ansible
yes | pacman -S python-requests   # Dependency

echo "Installing Fish Shell"
yes | pacman -S fish
chsh -s /usr/bin/fish vagrant

echo "Installing Docker"
yes | pacman -S docker
systemctl enable docker
usermod -aG docker vagrant

echo "Installing Neovim Dependencies"
yes | pacman -S tree-sitter

echo "Installing Neovim"
yes | pacman -S neovim
yes | pacman -S unzip   # Mason Dependency

echo "Installing TMUX - Dependencies"
yes | pacman -S bc

echo "Installing OpenCode - Dependencies"
yes | pacman -S lsof

echo "Installing Search Tools"
yes | pacman -S fd        # Faster Find
yes | pacman -S fzf       # Fuzzy Finder
yes | pacman -S ripgrep   # Faster Grep

echo "Installing Some Tools"
sudo pacman -S --noconfirm starship
yes | pacman -S mise
yes | pacman -S direnv
yes | pacman -S tmux
yes | pacman -S tmuxp
yes | pacman -S stow
yes | pacman -S git-delta
yes | pacman -S lazygit
yes | pacman -S htop
yes | pacman -S zoxide
yes | pacman -S fastfetch
yes | pacman -S tree
yes | pacman -S eza
yes | pacman -S bat
yes | pacman -S ncdu
yes | pacman -S jq
EOF

# Setup with YaY
arch-chroot /mnt /bin/bash -e <<EOF
su - vagrant
echo "Installing OpenCode"
yay -S --noconfirm opencode-bin

echo "Installing TPM - TMUX Plugin Manager"
yay -S --noconfirm tmux-plugin-manager

echo "Installing Neovim Dependencies with YaY"
yay -S --noconfirm tree-sitter-cli
EOF

# Write Fish Configuration
arch-chroot /mnt /bin/bash -e <<'EOF'
su - vagrant
echo "set fish_greeting" > /home/vagrant/.config/fish/config.fish
echo "" >> /home/vagrant/.config/fish/config.fish
echo "# Hooks" >> /home/vagrant/.config/fish/config.fish
echo "mise activate fish | source" >> /home/vagrant/.config/fish/config.fish
echo "direnv hook fish | source" >> /home/vagrant/.config/fish/config.fish
echo "starship init fish | source" >> /home/vagrant/.config/fish/config.fish
echo "zoxide init fish | source" >> /home/vagrant/.config/fish/config.fish
echo "" >> /home/vagrant/.config/fish/config.fish
echo "# Theme" >> /home/vagrant/.config/fish/config.fish
echo "set -gx TERM xterm-256color" >> /home/vagrant/.config/fish/config.fish
echo "" >> /home/vagrant/.config/fish/config.fish
echo "# General" >> /home/vagrant/.config/fish/config.fish
echo "set -gx EDITOR nvim" >> /home/vagrant/.config/fish/config.fish
echo "set -gx GIT_EDITOR $EDITOR" >> /home/vagrant/.config/fish/config.fish
EOF

# Remove Orphaned Packages (YaY handles Pacman orphans)
arch-chroot /mnt /bin/bash -e <<EOF
yay -Yc --noconfirm || true
EOF

# Clear Pacman Cache
arch-chroot /mnt /bin/bash -e <<EOF
yes | pacman -Scc || true
EOF

# Cleanup YaY Cache
arch-chroot /mnt /bin/bash -e <<EOF
rm -rf /tmp/yay
rm -rf ~/.cache/yay
EOF
