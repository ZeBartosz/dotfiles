#!/usr/bin/zsh
BAT="BAT0"
BPATH="/sys/class/power_supply/$BAT"

[ -d "$BPATH" ] || { echo "N/A"; exit 0; }

# If capacity is available, use it (simple case)
if [ -r "$BPATH/capacity" ]; then
  percent=$(cat "$BPATH/capacity" 2>/dev/null || echo "")
  bat_status=$(cat "$BPATH/status" 2>/dev/null || echo "")
  # Validate percent is numeric
  case "$percent" in ''|*[!0-9]*)
    echo "N/A"
    exit 0
    ;;
  esac

  if [ "$bat_status" = "Charging" ]; then
    printf "⚡ %d\n" "$percent"
  else
    printf "%d\n" "$percent"
  fi
  exit 0
fi

# Otherwise try energy_* or charge_* pairs
if [ -r "$BPATH/energy_now" ] && [ -r "$BPATH/energy_full" ]; then
  cur=$(cat "$BPATH/energy_now" 2>/dev/null || echo "")
  full=$(cat "$BPATH/energy_full" 2>/dev/null || echo "")
elif [ -r "$BPATH/charge_now" ] && [ -r "$BPATH/charge_full" ]; then
  cur=$(cat "$BPATH/charge_now" 2>/dev/null || echo "")
  full=$(cat "$BPATH/charge_full" 2>/dev/null || echo "")
else
  echo "N/A"
  exit 0
fi

# Validate numeric values
case "$cur" in ''|*[!0-9]*)
  echo "N/A"
  exit 0
  ;;
esac
case "$full" in ''|*[!0-9]*)
  echo "N/A"
  exit 0
  ;;
esac

percent=$(( cur * 100 / full ))
bat_status=$(cat "$BPATH/status" 2>/dev/null || echo "")

if [ "$bat_status" = "Charging" ]; then
  printf "⚡ %d\n" "$percent"
else
  printf "%d\n" "$percent"
fi
