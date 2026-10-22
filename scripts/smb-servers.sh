#!/usr/bin/env bash

# Check for required tools
for tool in jq gum; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Error: $tool is not installed. Please install it to continue."
    exit 1
  fi
done

if [ "$(uname)" = "Darwin" ]; then
  smb_tool=mount_smbfs
else
  smb_tool=mount.cifs
fi

# Check if either the SMB tool or sshfs is installed
if ! command -v "$smb_tool" >/dev/null 2>&1 && ! command -v sshfs >/dev/null 2>&1; then
  echo "Error: Neither $smb_tool nor sshfs is installed."
  exit 1
fi

# Check argument count
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

# Get and check for duplicate titles
titles=$(jq -r '.[].title' "$servers")
duplicate_titles=$(echo "$titles" | sort | uniq -d)
if [ -n "$duplicate_titles" ]; then
  echo "Error: Duplicate titles found in the JSON file:"
  echo "$duplicate_titles"
  exit 1
fi

# Let user choose a server
selected_title=$(echo "$titles" | gum choose)
user=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .user' "$servers")
hostname=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .hostname' "$servers")
password=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .password' "$servers")
subdirectory=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .subdirectory' "$servers")
mountpoint=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .mountpoint' "$servers")
protocol=$(jq -r --arg title "$selected_title" '.[] | select(.title == $title) | .protocol' "$servers")

# Expand mountpoint variable
eval mountpoint="$mountpoint"

# Validate required fields
if [ -z "$user" ] || [ -z "$hostname" ] || [ -z "$protocol" ]; then
  echo "Error: Missing required field (user, hostname, or protocol)."
  exit 1
fi

# Check subdirectory format
if ! grep -q "/" <<< "$subdirectory"; then
  echo "Error: The subdirectory must contain a '/'."
  exit 1
fi

# Create the mountpoint directory if it doesn't exist
mkdir -p "$mountpoint"

# Mount based on protocol
case "$protocol" in
  smb)
    if ! command -v "$smb_tool" >/dev/null 2>&1; then
      echo "Error: $smb_tool is required for SMB but not found."
      exit 1
    fi
    echo "Mounting SMB share..."
    if [ "$smb_tool" = "mount_smbfs" ]; then
      mount_smbfs "//$user:$password@${hostname}$subdirectory" "$mountpoint"
    else
      sudo mount -t cifs "//${hostname}$subdirectory" "$mountpoint" \
        -o "username=$user,password=$password,uid=$(id -u),gid=$(id -g)"
    fi
    ;;
  sshfs)
    if ! command -v sshfs >/dev/null 2>&1; then
      echo "Error: sshfs is required for SSHFS but not found."
      exit 1
    fi
    echo "Mounting SSHFS share..."
    sshfs -o allow_other "$user@$hostname:$subdirectory" "$mountpoint" -oauto_cache,reconnect,defer_permissions,noappledouble,nolocalcaches,no_readahead
    ;;
  *)
    echo "Error: Unsupported protocol '$protocol'. Use 'smb' or 'sshfs'."
    exit 1
    ;;
esac

echo "Mount successful at $mountpoint"

