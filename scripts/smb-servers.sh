#!/usr/bin/env bash

# Check for required tools
if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is not installed. Please install jq to continue."
  exit 1
fi
if ! command -v gum >/dev/null 2>&1; then
  echo "Error: gum is not installed. Please install gum to continue."
  exit 1
fi

if ! command -v mount_smbfs >/dev/null 2>&1; then
  echo "Error: mount_smbfs is not installed. Please install mount_smbfs to continue."
  exit 1
fi

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <servers.json>"
  exit 1
fi

servers="$1"

# Check if the JSON file exists
if [ ! -f "$servers" ]; then
  echo "Error: JSON file '$servers' does not exist."
  exit 1
fi

# Validate the JSON file
if ! jq empty "$servers" >/dev/null 2>&1; then
  echo "Error: JSON file '$servers' is not valid."
  exit 1
fi

titles=$(jq -r '.[].title' "$servers")
selected_title=$(echo "$titles" | gum choose)
user=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .user' "$servers")
hostname=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .hostname' "$servers")
password=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .password' "$servers")
subdirectory=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .subdirectory' "$servers")
mountpoint=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .mountpoint' "$servers")
eval mountpoint="$mountpoint"

# Check for duplicate titles
duplicate_titles=$(echo "$titles" | sort | uniq -d)
if [ -n "$duplicate_titles" ]; then
  echo "Error: Duplicate titles found in the JSON file:"
  echo "$duplicate_titles"
  exit 1
fi

# Check if user and hostname were found
if [ -z "$user" ] || [ -z "$hostname" ]; then
  echo "Error: Could not find user or hostname for the selected title."
  exit 1;
fi

if ! grep -q "/" <<< "$subdirectory"; then
  echo "Error: The subdirectory does not contain a '/'."
fi

mount_smbfs "//$user:$password@${hostname}$subdirectory" "$mountpoint"
