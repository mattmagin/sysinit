# Configuration

## Machine Profile

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

## Switching Themes

1. Open `~/.config/chezmoi/chezmoi.toml`
2. Change `[data.theme]` — update `name` and all color values from the desired theme's `colors.toml` (found in `~/.config/omarchy/themes/<name>/colors.toml`)
3. Run `chezmoi apply`

## Adding Packages

Edit `ansible/group_vars/all.yml` — add to the appropriate `packages_*` list or `aur_packages`, then re-run:

```bash
task ansible:packages
```

Or directly:

```bash
cd ~/dotfiles/ansible
ansible-playbook --connection=local -K setup.yml --tags packages
```

## Running Individual Ansible Roles

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

## Chezmoi Day-to-Day

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

## Using Taskfile

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

## Secret Management

- **Age encryption** via Chezmoi for static files (SSH keys, API tokens)
- Key auto-generated on first `chezmoi apply` at `~/.config/chezmoi/key.txt`
- Add encrypted files: `chezmoi add --encrypt ~/.ssh/id_ed25519`
