# Dotfiles — Arch Linux + Hyprland

A declarative system configuration for Arch Linux, using **Ansible** for system-level provisioning and **Chezmoi** for user-level dotfile management. Originally derived from [Omarchy](https://github.com/omakub/omarchy), rebuilt as a standalone, reproducible, two-machine setup.

## Quick Start

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./bootstrap.sh
```

The bootstrap script will install Ansible and Chezmoi, provision the system, prompt for machine-specific config, and apply all dotfiles. Log out and back in when done (your shell changes to zsh).

For detailed installation instructions, see [Installation Guide](docs/INSTALLATION.md).

## Architecture

```
dotfiles/
├── bootstrap.sh                    # One-command setup entry point
├── Taskfile.yml                    # Task runner for common commands
├── ansible/                        # System-level (needs sudo)
│   ├── setup.yml                   # Main playbook
│   ├── inventory/localhost.yml     # Local connection
│   ├── group_vars/all.yml          # All package lists, services, user config
│   └── roles/
│       ├── packages/               # Installs all pacman + AUR packages
│       ├── gpu/                    # Auto-detects AMD vs NVIDIA, installs drivers
│       ├── hardware/               # Framework 13, ASUS ROG detection
│       ├── system-config/          # /etc/ files (Docker, SDDM, logind, resolved, ...)
│       ├── services/               # Enables/disables/masks systemd services
│       ├── user/                   # Groups (docker, input, video), sets shell to zsh
│       └── dev-tools/              # Bootstraps Node.js + Bun via mise
└── chezmoi/                        # User-level (~/.config, ~/.zshrc, ...)
    ├── .chezmoi.toml.tmpl          # Machine profile, GPU, theme, git — prompted on init
    ├── run_once_before_*.sh        # One-time setup scripts (age key generation)
    ├── dot_zshrc                   # Zsh config with zinit plugins
    ├── dot_config/
    │   ├── hypr/                   # Full Hyprland config (self-contained)
    │   ├── ghostty/                # Terminal (auto-launches Zellij)
    │   ├── zellij/                 # Multiplexer (replaces tmux)
    │   ├── helix/                  # Terminal editor ($EDITOR)
    │   ├── waybar/                 # Status bar + themed CSS
    │   ├── mako/                   # Notification daemon
    │   ├── walker/                 # App launcher
    │   ├── elephant/               # Walker indexer (keyword search)
    │   ├── btop/                   # System monitor + themed
    │   ├── swayosd/                # OSD widget
    │   ├── starship.toml           # Prompt
    │   ├── git/                    # Git config (name/email from chezmoi data)
    │   └── omarchy/themes/         # 16 color themes with backgrounds
    └── private_dot_local/
        └── share/applications/     # .desktop files for walker search
```

## Documentation

- **[Installation](docs/INSTALLATION.md)** — Prerequisites, bootstrap process, and initial setup
- **[Configuration](docs/CONFIGURATION.md)** — Machine profiles, themes, packages, services, and day-to-day usage
- **[Components](docs/COMPONENTS.md)** — Desktop environment, terminal stack, editors, applications, CLI tools, themes, and keybindings
- **[Customization](docs/CUSTOMIZATION.md)** — Guide to modifying and extending the setup

## Prerequisites

A fresh Arch Linux install with a working internet connection. See the [Installation Guide](docs/INSTALLATION.md) for details.
