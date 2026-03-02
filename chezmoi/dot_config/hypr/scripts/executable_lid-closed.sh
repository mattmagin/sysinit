#!/bin/bash
# Handle laptop lid close: disable internal display if external monitors exist.
# If no external monitor, systemd-logind handles suspend.

if hyprctl monitors -j | jq -e '[.[] | select(.name != "eDP-1")] | length > 0' > /dev/null 2>&1; then
  hyprctl keyword monitor "eDP-1, disable"
fi
