#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <sites>"
  exit 1
fi

if ! command -v cliclick >/dev/null 2>&1; then
  echo "Error: cliclick is not installed. Please install cliclick to continue."
  exit 1
fi

if [ ! -f "$1" ]; then
  echo "Error: file '$1' does not exist."
  exit 1
fi

while IFS= read -r url || [[ -n $url ]]; do
  urls+=("$url")
done < "$1"

while true; do
  cliclick "m:$((RANDOM % 501)),$((RANDOM % 501))"
  sleep $((RANDOM % 151 + 30))
  len=${#urls[@]}
  rand_index=$((RANDOM % len))
  selected_url="${urls[$rand_index]}"
  curl -sS --insecure "$selected_url" > /dev/null
  cliclick "m:$((RANDOM % 501)),$((RANDOM % 501))"
  sleep $((RANDOM % 151 + 30))
done
