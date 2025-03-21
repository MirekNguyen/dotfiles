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

# Extract data from JSON file
titles=$(jq -r '.[].title' "$servers")
selected_title=$(echo "$titles" | gum filter)
user=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .user' "$servers")
hostname=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .hostname' "$servers")
password=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .password' "$servers")
extraArgs=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .extraArgs // ""' "$servers")

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

if [ -n "$password" ] && [ "$password" != "null" ]; then
  printf '%s' "$password" | pbcopy;
fi
eval ssh "$extraArgs" "$user@$hostname"
