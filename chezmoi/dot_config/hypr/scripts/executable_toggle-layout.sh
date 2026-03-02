#!/bin/bash
# Toggle between dwindle and master tiling layouts
# Bound to SUPER+M

current=$(hyprctl getoption general:layout -j | jq -r '.str')
if [[ "$current" == "dwindle" ]]; then
  hyprctl keyword general:layout master
  notify-send "Layout: Master" "Primary window + stack"
else
  hyprctl keyword general:layout dwindle
  notify-send "Layout: Dwindle" "Fibonacci-style splits"
fi
