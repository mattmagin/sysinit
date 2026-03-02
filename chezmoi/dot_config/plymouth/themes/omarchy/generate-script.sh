#!/bin/bash
# Generate Plymouth script from theme colors
# This script reads colors from chezmoi config and generates the Plymouth script

set -euo pipefail

CHEZMOI_CONFIG="$HOME/.config/chezmoi/chezmoi.toml"
SCRIPT_OUTPUT="$HOME/.config/plymouth/themes/omarchy/omarchy.script"

if [ ! -f "$CHEZMOI_CONFIG" ]; then
    echo "Error: Chezmoi config not found at $CHEZMOI_CONFIG"
    exit 1
fi

# Extract colors from chezmoi config (simple grep approach)
BG_COLOR=$(grep -A 20 "\[data.theme\]" "$CHEZMOI_CONFIG" | grep "^[[:space:]]*background" | cut -d'"' -f2)
FG_COLOR=$(grep -A 20 "\[data.theme\]" "$CHEZMOI_CONFIG" | grep "^[[:space:]]*foreground" | cut -d'"' -f2)
AC_COLOR=$(grep -A 20 "\[data.theme\]" "$CHEZMOI_CONFIG" | grep "^[[:space:]]*accent" | cut -d'"' -f2)

if [ -z "$BG_COLOR" ] || [ -z "$FG_COLOR" ] || [ -z "$AC_COLOR" ]; then
    echo "Error: Could not extract theme colors from $CHEZMOI_CONFIG"
    exit 1
fi

# Function to convert hex to RGB (0.0-1.0)
hex_to_rgb() {
    local hex=$(echo "$1" | tr '[:lower:]' '[:upper:]' | sed 's/#//')
    # Convert hex to decimal using printf
    local r=$((0x$(echo $hex | cut -c1-2)))
    local g=$((0x$(echo $hex | cut -c3-4)))
    local b=$((0x$(echo $hex | cut -c5-6)))
    # Convert to 0.0-1.0 range using awk for precision
    printf "%.3f, %.3f, %.3f" $(awk "BEGIN {printf \"%.3f %.3f %.3f\", $r/255, $g/255, $b/255}")
}

BG_RGB=$(hex_to_rgb "$BG_COLOR")
FG_RGB=$(hex_to_rgb "$FG_COLOR")
AC_RGB=$(hex_to_rgb "$AC_COLOR")

# Generate Plymouth script
cat > "$SCRIPT_OUTPUT" <<EOF
# Plymouth script for Omarchy disk encryption unlock UI
# Colors are generated from the current system theme
# Background: $BG_COLOR
# Foreground: $FG_COLOR
# Accent: $AC_COLOR

# Set background color (solid color matching theme background)
Window.SetBackgroundTopColor($BG_RGB);
Window.SetBackgroundBottomColor($BG_RGB);

# Set password box colors
PasswordBox.SetBackgroundColor($BG_RGB);
PasswordBox.SetForegroundColor($FG_RGB);

# Set prompt text color
PasswordBox.SetPromptColor($FG_RGB);

# Set entry text color (what you type)
PasswordBox.SetInputColor($FG_RGB);

# Set cursor color (accent color for visibility)
PasswordBox.SetCursorColor($AC_RGB);

# Set title (optional - can be empty for minimal UI)
Window.SetTitle("");

# Set password prompt text
PasswordBox.SetPromptText("Enter disk encryption password:");

# Center the password box on screen
PasswordBox.SetPosition(0, 0);
EOF

echo "Generated Plymouth script at $SCRIPT_OUTPUT"
