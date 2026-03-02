# Installation

## Prerequisites

A fresh Arch Linux install with a working internet connection. If you don't have one yet, follow the official guide:

**[Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide)**

You'll need at minimum: `base`, `base-devel`, `git`, `linux`, `linux-firmware`, and a bootloader. The bootstrap script handles everything else.

## Quick Start

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

## Bootstrap Process

The bootstrap script will:

1. Install Ansible and Chezmoi (if missing)
2. Run the Ansible playbook to provision the system (asks for `sudo` password)
3. Prompt you for machine-specific config (GPU type, display scale, theme, etc.)
4. Apply all dotfiles via Chezmoi

## Post-Installation

Log out and back in when done (your shell changes to zsh).
