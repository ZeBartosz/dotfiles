#!/bin/zsh

card=amdgpu_bl1
cur=$(cat /sys/class/backlight/$card/brightness 2>/dev/null || echo 0)
max=$(cat /sys/class/backlight/$card/max_brightness 2>/dev/null || echo 100)

if [ "$max" -gt 0 ]; then
  printf "%d\n" $((cur * 100 / max))
else
  echo "0"
fi
