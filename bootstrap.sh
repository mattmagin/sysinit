#!/bin/bash
set -euo pipefail

# ============================================================================
# Bootstrap script for provisioning a fresh Arch Linux system
#
# Usage (from a fresh Arch install with base packages):
#   git clone <this-repo> ~/dotfiles
#   cd ~/dotfiles
#   ./bootstrap.sh
#
# This script:
# 1. Installs Ansible and Chezmoi if not present
# 2. Runs Ansible playbook to configure the system (packages, GPU, services)
# 3. Initializes Chezmoi to manage user dotfiles
# ============================================================================

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ANSIBLE_DIR="$DOTFILES_DIR/ansible"
CHEZMOI_DIR="$DOTFILES_DIR/chezmoi"

echo "============================================"
echo "  Dotfiles bootstrap — Ansible + Chezmoi"
echo "============================================"
echo ""

# ---- Step 1: Ensure Ansible is installed ----
if ! command -v ansible-playbook &>/dev/null; then
  echo "→ Installing Ansible..."
  sudo pacman -S --noconfirm --needed ansible
fi

# ---- Step 2: Ensure Chezmoi is installed ----
if ! command -v chezmoi &>/dev/null; then
  echo "→ Installing Chezmoi..."
  sudo pacman -S --noconfirm --needed chezmoi
fi

# ---- Step 3: Ensure age is installed ----
if ! command -v age &>/dev/null; then
  echo "→ Installing age encryption..."
  sudo pacman -S --noconfirm --needed age
fi

# ---- Step 4: Run Ansible playbook ----
echo ""
echo "→ Running Ansible system provisioning..."
echo "  (You will be asked for your sudo password)"
echo ""

cd "$ANSIBLE_DIR"
ansible-playbook \
  --connection=local \
  --inventory inventory/localhost.yml \
  --ask-become-pass \
  setup.yml

echo ""
echo "✓ Ansible provisioning complete"

# ---- Step 5: Configure UFW firewall ----
echo ""
echo "→ Configuring firewall..."
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 53317/udp  # LocalSend
sudo ufw allow 53317/tcp  # LocalSend
sudo ufw allow in proto udp from 172.16.0.0/12 to 172.17.0.1 port 53 comment 'allow-docker-dns'
sudo ufw --force enable
echo "✓ Firewall configured"

# ---- Step 6: Initialize Chezmoi ----
echo ""
echo "→ Initializing Chezmoi..."
echo "  (You will be prompted for machine profile, GPU type, etc.)"
echo ""

chezmoi init --source="$CHEZMOI_DIR" --apply

echo ""
echo "✓ Chezmoi dotfiles applied"

# ---- Done! ----
echo ""
echo "============================================"
echo "  ✓ Bootstrap complete!"
echo ""
echo "  Next steps:"
echo "  1. Log out and back in (shell changed to zsh)"
echo "  2. Open Ghostty — it will auto-launch Zellij"
echo "  3. Run 'chezmoi diff' to see what's managed"
echo "  4. Add SSH keys:"
echo "     chezmoi add --encrypt ~/.ssh/id_ed25519"
echo "     chezmoi add --encrypt ~/.ssh/id_ed25519.pub"
echo "  5. Switch themes by editing ~/.config/chezmoi/chezmoi.toml"
echo "     then running: chezmoi apply"
echo "============================================"
