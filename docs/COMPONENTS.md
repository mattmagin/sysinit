# Components

## Hardware Profiles

The setup supports two machine profiles, auto-configured at `chezmoi init` time:

| Profile | GPU | Display | Notes |
|---|---|---|---|
| `framework13` | AMD (integrated) | 2256x1504 @ 1.504 scale | Lid switch handling, monitor hotplug daemon, known external monitors |
| `desktop` | AMD + NVIDIA | 5120x1440 ultrawide | NVIDIA env vars, open kernel module, CUDA |

GPU drivers are auto-detected by Ansible (`lspci`). NVIDIA supports both Turing+ (open-dkms) and legacy Maxwell/Pascal/Volta (580xx-dkms).

## Desktop Environment

- **Hyprland** — Wayland compositor with dwindle + master layouts
- **Waybar** — status bar (workspaces, clock, battery, network, audio, bluetooth)
- **Walker** — app launcher with keyword search (`SUPER+Space`)
- **Mako** — notification daemon
- **SwayOSD** — on-screen display for volume/brightness
- **Hyprlock** — lock screen
- **Hypridle** — idle manager
- **Hyprsunset** — blue light filter
- **SDDM** — display manager with autologin

## Terminal Stack

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

## Editors

- **Cursor** — primary GUI editor (`$VISUAL`)
- **Helix** — terminal editor (`$EDITOR`)
- **Neovim** — installed but not default

## Applications

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

## CLI Tools

`eza` `bat` `ripgrep` `fd` `fzf` `zoxide` `dust` `jq` `tldr` `lazygit` `lazydocker` `btop` `fastfetch` `gum` `go-task` `mise` (Node.js, Bun) `opencode` `starship` `plocate` `github-cli`

## System Services

Enabled by Ansible: `bluetooth`, `cups`, `cups-browsed`, `avahi-daemon`, `docker`, `iwd`, `sddm`, `ufw`

## Themes

16 themes with matching colors across Ghostty, Hyprland borders, Waybar, Mako, SwayOSD, Walker, Btop, and Hyprlock:

`catppuccin` · `catppuccin-latte` · `ethereal` · `everforest` · `flexoki-light` · `gruvbox` · `hackerman` · `kanagawa` · `matte-black` · `miasma` · `nord` · `osaka-jade` · `ristretto` · `rose-pine` · `tokyo-night` · `vantablack`

Each theme includes `colors.toml`, wallpapers, and app-specific overrides.

## Monitor Handling (Framework 13)

On the `framework13` profile, a Hyprland IPC daemon (`monitor-handler.sh`) handles:

- **External plugged in** — becomes primary, workspace 1 moves to it
- **External unplugged** — focuses remaining monitor
- **External unplugged while lid closed** — re-enables internal display (prevents blind system)
- **Lid closed with external** — disables internal display
- **Lid closed without external** — systemd-logind suspends
- **Lid opened** — re-enables internal display

## Keybindings (Highlights)

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
