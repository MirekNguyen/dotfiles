#!/usr/bin/env bash
# Monitor brightness over DDC/CI in 5% steps. Usage: brightness.sh up|down
# Started on key press, steps until the key is released (keybinds.lua kills it).
set -u

for pid in $(pgrep -f "brightness.sh (up|down)"); do
  [ "$pid" = $$ ] || kill "$pid" 2>/dev/null
done

file=$XDG_RUNTIME_DIR/brightness
[ -s "$file" ] || ddcutil --bus 10 --brief getvcp 10 | awk '{print int($4 / 5) * 5}' > "$file"
value=$(cat "$file")
step=$([ "$1" = up ] && echo 5 || echo -5)

delay=0.3
while true; do
  value=$((value + step))
  value=$((value < 0 ? 0 : value > 100 ? 100 : value))
  echo $value > "$file"
  swayosd-client --custom-icon display-brightness-symbolic \
    --custom-progress "$(awk "BEGIN {print $value / 100}")" \
    --custom-progress-text "$value%" &
  ddcutil --bus 10 --noverify --skip-ddc-checks --sleep-multiplier 0.1 setvcp 10 $value
  sleep $delay
  delay=0
done
