# Dotfiles — Arch Linux + Hyprland

A declarative system configuration for Arch Linux, using **Ansible** for system-level provisioning and **Chezmoi** for user-level dotfile management. Originally derived from [Omarchy](https://github.com/omakub/omarchy), rebuilt as a standalone, reproducible, two-machine setup.

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

The bootstrap script will:

1. Install Ansible and Chezmoi (if missing)
2. Run the Ansible playbook to provision the system (asks for `sudo` password)
3. Prompt you for machine-specific config (GPU type, display scale, theme, etc.)
4. Apply all dotfiles via Chezmoi

Log out and back in when done (your shell changes to zsh).

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

## Hardware Profiles

The setup supports two machine profiles, auto-configured at `chezmoi init` time:

| Profile | GPU | Display | Notes |
|---|---|---|---|
| `framework13` | AMD (integrated) | 2256x1504 @ 1.504 scale | Lid switch handling, monitor hotplug daemon, known external monitors |
| `desktop` | AMD + NVIDIA | 5120x1440 ultrawide | NVIDIA env vars, open kernel module, CUDA |

GPU drivers are auto-detected by Ansible (`lspci`). NVIDIA supports both Turing+ (open-dkms) and legacy Maxwell/Pascal/Volta (580xx-dkms).

## What's Included

### Desktop Environment

- **Hyprland** — Wayland compositor with dwindle + master layouts
- **Waybar** — status bar (workspaces, clock, battery, network, audio, bluetooth)
- **Walker** — app launcher with keyword search (`SUPER+Space`)
- **Mako** — notification daemon
- **SwayOSD** — on-screen display for volume/brightness
- **Hyprlock** — lock screen
- **Hypridle** — idle manager
- **Hyprsunset** — blue light filter
- **SDDM** — display manager with autologin

### Terminal Stack

- **Ghostty** — GPU-accelerated terminal (auto-launches Zellij)
- **Zellij** — terminal multiplexer with tab bar + status bar
- **Zsh** — shell with [zinit](https://github.com/zdharma-continuum/zinit) plugins:
  - `zsh-autosuggestions` — fish-style greyed-out suggestions
  - `fast-syntax-highlighting` — commands turn green/red as you type
  - `zsh-completions` — rich tab completions for 200+ tools
  - `zsh-history-substring-search` — type partial, arrow keys to filter
  - `zsh-autopair` — auto-close brackets and quotes
  - `zsh-you-should-use` — reminds you about existing aliases
- **Starship** — minimal prompt showing directory + git status

### Editors

- **Cursor** — primary GUI editor (`$VISUAL`)
- **Helix** — terminal editor (`$EDITOR`)
- **Neovim** — installed but not default

### Applications

| App | Replaces | Purpose |
|---|---|---|
| Helium | Chromium | Web browser (Chromium fork) |
| Bitwarden | 1Password | Password manager |
| Beeper | Signal + WhatsApp web | Unified messaging |
| Slack | — | Team communication |
| Discord | — | Voice and text chat |
| DaVinci Resolve | Kdenlive | Video editing |
| OrcaSlicer | — | 3D printer slicer |
| Obsidian | — | Notes |
| OBS Studio | — | Streaming / recording |
| Nautilus | — | File manager |

### CLI Tools

`eza` `bat` `ripgrep` `fd` `fzf` `zoxide` `dust` `jq` `tldr` `lazygit` `lazydocker` `btop` `fastfetch` `gum` `go-task` `mise` (Node.js, Bun) `opencode` `starship` `plocate` `github-cli`

### System Services

Enabled by Ansible: `bluetooth`, `cups`, `cups-browsed`, `avahi-daemon`, `docker`, `iwd`, `sddm`, `ufw`

### Themes

16 themes with matching colors across Ghostty, Hyprland borders, Waybar, Mako, SwayOSD, Walker, Btop, and Hyprlock:

`catppuccin` · `catppuccin-latte` · `ethereal` · `everforest` · `flexoki-light` · `gruvbox` · `hackerman` · `kanagawa` · `matte-black` · `miasma` · `nord` · `osaka-jade` · `ristretto` · `rose-pine` · `tokyo-night` · `vantablack`

Each theme includes `colors.toml`, wallpapers, and app-specific overrides.

### Monitor Handling (Framework 13)

On the `framework13` profile, a Hyprland IPC daemon (`monitor-handler.sh`) handles:

- **External plugged in** — becomes primary, workspace 1 moves to it
- **External unplugged** — focuses remaining monitor
- **External unplugged while lid closed** — re-enables internal display (prevents blind system)
- **Lid closed with external** — disables internal display
- **Lid closed without external** — systemd-logind suspends
- **Lid opened** — re-enables internal display

### Keybindings (Highlights)

| Binding | Action |
|---|---|
| `SUPER+Return` | Terminal (Ghostty) |
| `SUPER+Space` | App launcher (Walker) |
| `SUPER+M` | Toggle layout (dwindle ↔ master) |
| `SUPER+W` | Close window |
| `SUPER+F` | Fullscreen |
| `SUPER+T` | Toggle floating |
| `SUPER+1-0` | Switch workspace |
| `SUPER+Shift+1-0` | Move window to workspace |
| `SUPER+S` | Toggle scratchpad |
| `SUPER+Ctrl+L` | Lock screen |
| `SUPER+Escape` | System menu |

Full list: `SUPER+K` to see all bindings.

### Secret Management

- **Age encryption** via Chezmoi for static files (SSH keys, API tokens)
- Key auto-generated on first `chezmoi apply` at `~/.config/chezmoi/key.txt`
- Add encrypted files: `chezmoi add --encrypt ~/.ssh/id_ed25519`

## Configuration

### Machine Profile

Set during `chezmoi init`. To change later, edit `~/.config/chezmoi/chezmoi.toml`:

```toml
[data.machine]
  profile = "framework13"  # or "desktop"
[data.gpu]
  type = "amd"             # or "nvidia"
[data.display]
  scale = 1.504
  gdk_scale = 2
```

Then run `chezmoi apply` to regenerate all templated configs.

### Switching Themes

1. Open `~/.config/chezmoi/chezmoi.toml`
2. Change `[data.theme]` — update `name` and all color values from the desired theme's `colors.toml` (found in `~/.config/omarchy/themes/<name>/colors.toml`)
3. Run `chezmoi apply`

### Adding Packages

Edit `ansible/group_vars/all.yml` — add to the appropriate `packages_*` list or `aur_packages`, then re-run:

```bash
task ansible:packages
```

Or directly:

```bash
cd ~/dotfiles/ansible
ansible-playbook --connection=local -K setup.yml --tags packages
```

### Running Individual Ansible Roles

Using Taskfile (recommended):

```bash
task ansible:gpu
task ansible:hardware
task ansible:system-config
task ansible:services
task ansible:user
task ansible:dev-tools
```

Or directly with Ansible:

```bash
cd ~/dotfiles/ansible
ansible-playbook --connection=local -K setup.yml --tags gpu
ansible-playbook --connection=local -K setup.yml --tags hardware
ansible-playbook --connection=local -K setup.yml --tags system-config
ansible-playbook --connection=local -K setup.yml --tags services
ansible-playbook --connection=local -K setup.yml --tags user
ansible-playbook --connection=local -K setup.yml --tags dev-tools
```

### Chezmoi Day-to-Day

Using Taskfile:

```bash
task chezmoi:diff   # Preview pending changes
task chezmoi:apply  # Apply all changes
```

Or directly:

```bash
chezmoi diff          # Preview pending changes
chezmoi apply         # Apply all changes
chezmoi edit ~/.zshrc # Edit managed file, then apply
chezmoi add <file>    # Start managing a new file
chezmoi add --encrypt <file>  # Add with age encryption
chezmoi cd            # cd into the chezmoi source directory
```

### Using Taskfile

The project includes a `Taskfile.yml` that wraps common Ansible and Chezmoi commands. After installing `go-task` (included in the package list), you can use:

```bash
task                       # List all available tasks
task bootstrap             # Full system setup from scratch
task ansible               # Run full Ansible playbook
task ansible:packages      # Install/update packages only
task ansible:gpu           # GPU driver setup
task ansible:hardware      # Hardware-specific config
task ansible:system-config # System config files (/etc/)
task ansible:services      # Enable/disable systemd services
task ansible:user          # User groups and shell
task ansible:dev-tools     # Dev tool bootstrapping (mise, bun)
task chezmoi:apply         # Apply dotfiles
task chezmoi:diff          # Preview pending dotfile changes
task chezmoi:init          # Initialize chezmoi (prompts for config)
task apply                 # Run full Ansible + Chezmoi apply
```

## Modifying & Extending

This section explains how to make common modifications. The key rule: **system-level changes go in Ansible, user-level changes go in Chezmoi**.

### Adding a New Machine Profile

Say you get a new laptop (e.g. a ThinkPad X1 Carbon):

1. **Chezmoi data** — edit `chezmoi/.chezmoi.toml.tmpl` and add your profile name as an option (it's freeform — just pick a slug like `thinkpad-x1`).

2. **Monitor config** — edit `chezmoi/dot_config/hypr/monitors.conf.tmpl` and add a new `{{ else if }}` block:

   ```gotemplate
   {{ else if eq .machine.profile "thinkpad-x1" -}}
   monitor = eDP-1, 2560x1600@60, auto, 1.6
   monitor = , preferred, auto, auto
   {{ end -}}
   ```

3. **Conditional features** — if this machine needs lid switch handling, add it to `bindings.conf.tmpl` and `autostart.conf.tmpl` alongside the existing `framework13` conditions:

   ```gotemplate
   {{ if or (eq .machine.profile "framework13") (eq .machine.profile "thinkpad-x1") -}}
   ```

4. **Hardware-specific Ansible** — if the machine needs special drivers or firmware, add detection logic in `ansible/roles/hardware/tasks/main.yml` following the existing Framework 13 pattern.

5. Re-run `chezmoi init` to set the new profile, then `chezmoi apply`.

### Adding a New Application

**GUI app (from AUR):**

1. Add the package name to `aur_packages` in `ansible/group_vars/all.yml`
2. Optionally create a `.desktop` file in `chezmoi/private_dot_local/share/applications/` with `Keywords=` for Walker search
3. If it needs window rules (floating, size, etc.), add them to `chezmoi/dot_config/hypr/windows.conf`
4. Run:
   ```bash
   task ansible:packages
   task chezmoi:apply
   ```

**CLI tool (from pacman):**

1. Add to the appropriate `packages_*` list in `ansible/group_vars/all.yml`
2. If it needs shell integration, add an `eval` block in `chezmoi/dot_zshrc` (follow the existing `mise`/`zoxide`/`fzf` pattern)
3. Run: `task ansible:packages`

### Removing an Application

1. Remove from the package list in `ansible/group_vars/all.yml`
2. Remove any related `.desktop` file from `chezmoi/private_dot_local/share/applications/`
3. Remove any window rules from `chezmoi/dot_config/hypr/windows.conf`
4. Remove any shell aliases/integrations from `chezmoi/dot_zshrc`
5. Uninstall manually: `sudo pacman -Rns <package>` or `yay -Rns <package>`

Note: Ansible's `state: present` won't remove packages — it only ensures they're installed. You need to remove them manually the first time.

### Replacing a Component

**Switching terminal emulator** (e.g. Ghostty → Alacritty):

1. Swap package: in `ansible/group_vars/all.yml`, replace `ghostty` with `alacritty` in `packages_terminal`
2. Replace config: delete `chezmoi/dot_config/ghostty/`, create `chezmoi/dot_config/alacritty/` with your config (use `.tmpl` suffix if it needs theme colors)
3. Update Zellij auto-launch: either move it to the new terminal's config or remove `command = zellij attach --create default` and launch Zellij manually
4. Update `chezmoi/dot_config/hypr/windows.conf` to adjust any terminal-specific window rules
5. Update `$TERMINAL` in `chezmoi/dot_zshrc`

**Switching shell** (e.g. Zsh → Fish):

1. Swap package: replace `zsh` with `fish` in `packages_terminal`
2. Change `user_shell` in `ansible/group_vars/all.yml` to `/usr/bin/fish`
3. Replace `chezmoi/dot_zshrc` with a `dot_config/fish/config.fish` (port aliases, tool integrations)
4. Re-run Ansible user role: `task ansible:user`

**Switching editor:**

1. Change `$EDITOR` and/or `$VISUAL` in `chezmoi/dot_zshrc`
2. Update `chezmoi/dot_config/git/config.tmpl` to change `editor = ...`
3. Swap packages if needed in `ansible/group_vars/all.yml`
4. Replace the editor config dir under `chezmoi/dot_config/`

### Adding a New Systemd Service

1. Add the package providing the service to the appropriate list in `ansible/group_vars/all.yml`
2. Add the service name to `services_enabled` (same file)
3. If it needs config files under `/etc/`, add tasks to `ansible/roles/system-config/tasks/main.yml`
4. Run: `task ansible:packages ansible:services ansible:system-config`

### Adding a New Theme

1. Create a directory under `chezmoi/dot_config/omarchy/themes/<name>/` containing at minimum:
   - `colors.toml` — 16 ANSI colors + accent, cursor, foreground, background, selection colors (follow the format of any existing theme)
   - `backgrounds/` — one or more wallpaper images
2. Copy the color values from your new `colors.toml` into `~/.config/chezmoi/chezmoi.toml` under `[data.theme]`
3. Run `chezmoi apply` — all themed configs (Ghostty, Waybar, Mako, etc.) regenerate automatically

### Adding a `.desktop` Entry for Walker

Walker finds apps via `.desktop` files. To make a web app, script, or system action searchable:

1. Create a file in `chezmoi/private_dot_local/share/applications/MyThing.desktop`:

   ```ini
   [Desktop Entry]
   Name=My Thing
   GenericName=Description for search
   Exec=my-command %U
   Icon=icon-name
   Terminal=false
   Type=Application
   Categories=Utility;
   Keywords=search;terms;people;might;type;
   NoDisplay=true
   ```

2. `Keywords=` is the key field — add every synonym someone might search for
3. `NoDisplay=true` hides it from app menus but keeps it in Walker search
4. Run `chezmoi apply`

### Modifying Hyprland Keybindings

All keybindings are in `chezmoi/dot_config/hypr/bindings.conf.tmpl`. The format is:

```
bindd = MODIFIERS, KEY, Description, dispatcher, args
```

- `bindd` = bound with description (shows in `SUPER+K` help)
- `bindld` = locked + described (works on lock screen)
- `bindeld` = locked + described + repeat on hold

To add a new binding:

```
bindd = SUPER SHIFT, B, Browser, exec, helium-browser
```

To remove one, delete or comment the line. Machine-specific bindings use Go template conditionals:

```gotemplate
{{ if eq .machine.profile "framework13" -}}
bindl = , switch:on:Lid Switch, exec, ~/.config/hypr/scripts/lid-closed.sh
{{ end -}}
```

After editing, run `chezmoi apply` and `hyprctl reload`.

### Where Things Live (Quick Reference)

| I want to change... | Edit this file |
|---|---|
| Installed packages | `ansible/group_vars/all.yml` |
| GPU / driver config | `ansible/roles/gpu/tasks/main.yml` |
| Files under `/etc/` | `ansible/roles/system-config/tasks/main.yml` |
| Systemd services | `ansible/group_vars/all.yml` → `services_enabled` |
| User groups or shell | `ansible/group_vars/all.yml` → `user_groups` / `user_shell` |
| Shell aliases & functions | `chezmoi/dot_zshrc` |
| Environment variables | `chezmoi/dot_zshrc` (shell) or `chezmoi/dot_config/hypr/envs.conf.tmpl` (Hyprland) |
| Keybindings | `chezmoi/dot_config/hypr/bindings.conf.tmpl` |
| Monitor layout | `chezmoi/dot_config/hypr/monitors.conf.tmpl` |
| Window rules | `chezmoi/dot_config/hypr/windows.conf` |
| Autostart programs | `chezmoi/dot_config/hypr/autostart.conf.tmpl` |
| Theme colors | `~/.config/chezmoi/chezmoi.toml` → `[data.theme]` |
| Terminal config | `chezmoi/dot_config/ghostty/config.tmpl` |
| Multiplexer config | `chezmoi/dot_config/zellij/config.kdl` |
| Git config | `chezmoi/dot_config/git/config.tmpl` |
| App launcher | `chezmoi/dot_config/walker/config.toml` |
| Notification daemon | `chezmoi/dot_config/mako/config.tmpl` |
| Status bar | `chezmoi/dot_config/waybar/config.jsonc` + `style.css.tmpl` |
| Prompt | `chezmoi/dot_config/starship.toml` |
| Searchable apps | `chezmoi/private_dot_local/share/applications/*.desktop` |
| Encrypted secrets | `chezmoi add --encrypt <file>` |

## Decisions & Opinionated Choices

- **Click-to-focus** — `follow_mouse = 0` (hover doesn't steal focus)
- **No Caps Lock remap** — `kb_options` is empty
- **No per-app keybindings** — use `SUPER+Space` (Walker) to launch everything
- **Ghostty auto-launches Zellij** — one terminal, one multiplexer
- **Dwindle default layout** — toggle to master with `SUPER+M`
- **`$EDITOR=hx`** — Helix for terminal editing, Cursor for GUI
