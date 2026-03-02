#!/bin/bash
# Generate age encryption key if it doesn't exist
# This key is used by chezmoi to decrypt encrypted files (SSH keys, API tokens, etc.)

KEY_FILE="$HOME/.config/chezmoi/key.txt"

if [[ ! -f "$KEY_FILE" ]]; then
  mkdir -p "$(dirname "$KEY_FILE")"
  age-keygen -o "$KEY_FILE" 2>/dev/null
  chmod 600 "$KEY_FILE"
  echo "=================================================="
  echo "  Age encryption key generated at: $KEY_FILE"
  echo "  Public key: $(grep 'public key:' "$KEY_FILE" | cut -d' ' -f4)"
  echo ""
  echo "  Update the 'recipient' in .chezmoi.toml with"
  echo "  the public key above, then re-add encrypted files:"
  echo "    chezmoi add --encrypt ~/.ssh/id_ed25519"
  echo "    chezmoi add --encrypt ~/.ssh/id_ed25519.pub"
  echo "=================================================="
fi
