#!/bin/bash
# Install Omarchy Plymouth theme after Chezmoi applies theme files
# This script runs once after chezmoi apply to generate and install the theme

set -euo pipefail

THEME_SOURCE_DIR="$HOME/.config/plymouth/themes/omarchy"
THEME_DEST_DIR="/usr/share/plymouth/themes/omarchy"

# Generate Plymouth script from theme colors
if [ -f "${THEME_SOURCE_DIR}/generate-script.sh" ]; then
    echo "Generating Plymouth script from theme colors..."
    "${THEME_SOURCE_DIR}/generate-script.sh" || {
        echo "Warning: Failed to generate Plymouth script"
        exit 0
    }
fi

# Check if theme files exist
if [ ! -f "${THEME_SOURCE_DIR}/omarchy.plymouth" ] || [ ! -f "${THEME_SOURCE_DIR}/omarchy.script" ]; then
    echo "Plymouth theme files not found at ${THEME_SOURCE_DIR}"
    echo "Skipping Plymouth theme installation"
    exit 0
fi

# Check if running as root or with sudo
if [ "$EUID" -ne 0 ]; then
    echo "Installing Plymouth theme requires sudo privileges"
    echo "Run: sudo ${THEME_SOURCE_DIR}/install.sh"
    echo "Or run: sudo cp ${THEME_SOURCE_DIR}/* ${THEME_DEST_DIR}/"
    exit 0
fi

# Create destination directory
mkdir -p "${THEME_DEST_DIR}"

# Copy theme files
cp "${THEME_SOURCE_DIR}/omarchy.plymouth" "${THEME_DEST_DIR}/"
cp "${THEME_SOURCE_DIR}/omarchy.script" "${THEME_DEST_DIR}/"

# Set proper permissions
chmod 644 "${THEME_DEST_DIR}/omarchy.plymouth"
chmod 644 "${THEME_DEST_DIR}/omarchy.script"

# Set as default theme and update initramfs
if command -v plymouth-set-default-theme &> /dev/null; then
    plymouth-set-default-theme omarchy
    plymouth-set-default-theme -R
    echo "Omarchy Plymouth theme installed and activated"
else
    echo "Warning: plymouth-set-default-theme not found - theme files copied but not activated"
fi
