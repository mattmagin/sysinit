# Customization

This section explains how to make common modifications. The key rule: **system-level changes go in Ansible, user-level changes go in Chezmoi**.

## Adding a New Machine Profile

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

## Adding a New Application

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

## Removing an Application

1. Remove from the package list in `ansible/group_vars/all.yml`
2. Remove any related `.desktop` file from `chezmoi/private_dot_local/share/applications/`
3. Remove any window rules from `chezmoi/dot_config/hypr/windows.conf`
4. Remove any shell aliases/integrations from `chezmoi/dot_zshrc`
5. Uninstall manually: `sudo pacman -Rns <package>` or `yay -Rns <package>`

Note: Ansible's `state: present` won't remove packages — it only ensures they're installed. You need to remove them manually the first time.

## Replacing a Component

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

## Adding a New Systemd Service

1. Add the package providing the service to the appropriate list in `ansible/group_vars/all.yml`
2. Add the service name to `services_enabled` (same file)
3. If it needs config files under `/etc/`, add tasks to `ansible/roles/system-config/tasks/main.yml`
4. Run: `task ansible:packages ansible:services ansible:system-config`

## Adding a New Theme

1. Create a directory under `chezmoi/dot_config/omarchy/themes/<name>/` containing at minimum:
   - `colors.toml` — 16 ANSI colors + accent, cursor, foreground, background, selection colors (follow the format of any existing theme)
   - `backgrounds/` — one or more wallpaper images
2. Copy the color values from your new `colors.toml` into `~/.config/chezmoi/chezmoi.toml` under `[data.theme]`
3. Run `chezmoi apply` — all themed configs (Ghostty, Waybar, Mako, etc.) regenerate automatically

## Adding a `.desktop` Entry for Walker

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

## Modifying Hyprland Keybindings

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

## Where Things Live (Quick Reference)

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
