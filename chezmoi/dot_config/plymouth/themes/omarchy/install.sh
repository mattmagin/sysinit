#!/bin/bash
# Install script for Omarchy Plymouth theme
# This script copies the theme to the system Plymouth themes directory

set -euo pipefail

THEME_NAME="omarchy"
THEME_SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_DEST_DIR="/usr/share/plymouth/themes/${THEME_NAME}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)"
    exit 1
fi

# Create destination directory
mkdir -p "${THEME_DEST_DIR}"

# Copy theme files
cp "${THEME_SOURCE_DIR}/omarchy.plymouth" "${THEME_DEST_DIR}/"
cp "${THEME_SOURCE_DIR}/omarchy.script" "${THEME_DEST_DIR}/"

# Set proper permissions
chmod 644 "${THEME_DEST_DIR}/omarchy.plymouth"
chmod 644 "${THEME_DEST_DIR}/omarchy.script"

echo "Omarchy Plymouth theme installed to ${THEME_DEST_DIR}"
echo "Run 'plymouth-set-default-theme omarchy' to set as default (or use Ansible)"
