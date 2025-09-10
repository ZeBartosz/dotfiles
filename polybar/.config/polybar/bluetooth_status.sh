#!/usr/bin/zsh

LOG=/tmp/polybar-bt.log
: >"$LOG"
log() { printf '%s\n' "$*" >>"$LOG"; }

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"

get_powered() {
  if command -v bluetoothctl >/dev/null 2>&1; then
    out=$(bluetoothctl show 2>/dev/null) || {
      log "bluetoothctl show failed"
      echo "off"
      return
    }
    # find Powered: yes/no (case-insensitive)
    powered=$(echo "$out" | awk -F': ' '/[Pp]owered/ {print tolower($2); exit}')
    if [[ -z "$powered" ]]; then
      echo "Off"
    elif [[ "$powered" == "yes" || "$powered" == "on" ]]; then
      echo "On"
    else
      echo "Off"
    fi
  elif command -v rfkill >/dev/null 2>&1; then
    if rfkill list bluetooth 2>/dev/null | grep -iq "Soft blocked: yes"; then
      echo "Off"
    else
      echo "On"
    fi
  else
    log "neither bluetoothctl nor rfkill available"
    echo "Off"
  fi
}

log "status script started"
state=$(get_powered)
log "detected state: $state"
printf '%s\n' "$state"
