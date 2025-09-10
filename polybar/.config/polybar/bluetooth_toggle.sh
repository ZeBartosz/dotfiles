#!/usr/bin/zsh

# Try to toggle using bluetoothctl first; fallback to rfkill
toggle_with_bluetoothctl() {
  # check current state and flip
  state=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered/ {print tolower($2); exit}')
  if [[ "$state" == "yes" || "$state" == "on" ]]; then
    bluetoothctl power off >/dev/null 2>&1 && return 0
  else
    bluetoothctl power on >/dev/null 2>&1 && return 0
  fi
  return 1
}

toggle_with_rfkill() {
  # If rfkill lists bluetooth, toggle soft block
  if rfkill list bluetooth >/dev/null 2>&1; then
    if rfkill list bluetooth | grep -qi "Soft blocked: yes"; then
      rfkill unblock bluetooth && return 0
    else
      rfkill block bluetooth && return 0
    fi
  fi
  return 1
}

if command -v bluetoothctl >/dev/null 2>&1; then
  toggle_with_bluetoothctl && exit 0
fi

if command -v rfkill >/dev/null 2>&1; then
  toggle_with_rfkill && exit 0
fi

# If we get here, try a fallback using systemctl (some distros use bluetooth.service)
if command -v systemctl >/dev/null 2>&1; then
  # if service is active, stop it; otherwise start it. This may not change controller power.
  if systemctl is-active --quiet bluetooth; then
    systemctl stop bluetooth && exit 0
  else
    systemctl start bluetooth && exit 0
  fi
fi

exit 1
