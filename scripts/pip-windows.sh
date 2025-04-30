#!/usr/bin/env bash

ws=${1:-$AEROSPACE_FOCUSED_WORKSPACE}
IFS=$'\n' all_wins=$(aerospace list-windows --all --format '%{window-id}|%{app-name}|%{window-title}|%{monitor-id}|%{workspace}')
pip_titles=("Picture-in-Picture" "Picture in Picture")

find_pip_windows() {
  local titles=("$@")
  local result=""
  local matches=""
  for title in "${titles[@]}"; do
    matches=$(printf '%s\n' "$all_wins" | grep -i "$title")
    result="$result"$'\n'"$matches"
  done
  echo "$result" | sed '/^\s*$/d'
}

pip_wins=$(find_pip_windows "${pip_titles[@]}")

move_win() {
  local win="$1"
  local win_id=""
  local win_ws=""

  [[ -n $win ]] || return 0

  win_id=$(echo "$win" | cut -d'|' -f1 | xargs)
  win_ws=$(echo "$win" | cut -d'|' -f5 | xargs)

  [[ $ws == "$win_ws" ]] && return 0

  aerospace move-node-to-workspace --window-id "$win_id" "$ws"
}

for win in $pip_wins; do
  move_win "$win"
done
