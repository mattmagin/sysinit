#!/bin/bash
# Monitor hotplug daemon — listens to Hyprland IPC for monitor events.
# Started by autostart.conf on Framework 13 only.
#
# Requires: socat, jq
#
# Behavior:
# - External plugged in  → becomes primary (workspace 1 moves to it)
# - External unplugged   → focus remaining monitor
# - External unplugged while lid closed → re-enable eDP-1 (prevents zero-monitor state)

handle_event() {
  case "$1" in
    monitoradded*)
      monitor_name="${1#monitoradded>>}"
      if [[ "$monitor_name" != "eDP-1" ]]; then
        sleep 0.5  # Let Hyprland finish configuring the display
        # Move workspace 1 to the new external monitor (makes it primary)
        hyprctl dispatch moveworkspacetomonitor "1 $monitor_name"
        # Move focus to the external monitor
        hyprctl dispatch focusmonitor "$monitor_name"
      fi
      ;;
    monitorremoved*)
      sleep 0.3
      # Check how many monitors remain active
      remaining=$(hyprctl monitors -j | jq -r '.[].name' 2>/dev/null)

      if [[ -z "$remaining" ]]; then
        # ZERO monitors — lid is closed and external was unplugged.
        # Re-enable internal display immediately to prevent a blind system.
        hyprctl keyword monitor "eDP-1, 2256x1504@60, auto, 1.504"
      else
        # At least one monitor remains — just focus it
        hyprctl dispatch focusmonitor "$(echo "$remaining" | head -1)"
      fi
      ;;
  esac
}

# Connect to Hyprland's event socket
socat -U - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r event; do
  handle_event "$event"
done
