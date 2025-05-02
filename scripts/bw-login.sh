#!/usr/bin/env bash

# bwlogin.sh - Bitwarden login selector and credential copier with continuous operation

# Fetch all items from Bitwarden
echo "Fetching items from Bitwarden..."
ITEMS=$(bw list items)

# Use fzf to select a login
SELECTED_ITEM=$(echo "$ITEMS" | jq -r '.[] | select(.type == 1) | "\(.name) | \(.login.username)"' | fzf --height 40% --border --prompt="Select login: ")

if [ -z "$SELECTED_ITEM" ]; then
  echo "No item selected"
  exit 0
fi

# Extract the name from the selection
ITEM_NAME=$(echo "$SELECTED_ITEM" | cut -d '|' -f 1 | xargs)

# Get the full item details
ITEM_DETAILS=$(echo "$ITEMS" | jq -r --arg name "$ITEM_NAME" '.[] | select(.name == $name)')

# Get username and password
USERNAME=$(echo "$ITEM_DETAILS" | jq -r '.login.username')
PASSWORD=$(echo "$ITEM_DETAILS" | jq -r '.login.password')

# Function to clear clipboard after a delay
clear_clipboard_later() {
  # Cancel any previous clipboard clearing jobs
  if [ ! -z "$CLIPBOARD_PID" ] && ps -p $CLIPBOARD_PID > /dev/null; then
    kill $CLIPBOARD_PID 2>/dev/null
  fi
  
  # Start a new clipboard clearing job
  (sleep 30 && echo "" | pbcopy) &
  CLIPBOARD_PID=$!
  echo "Clipboard will be cleared in 30 seconds"
}

# Main loop for continuous operation
while true; do
  echo "Selected: $ITEM_NAME"
  echo "-------------------"
  
  # Use gum to choose what to copy
  CHOICE=$(gum choose "Copy Username" "Copy Password" "Show Both" "Select Different Login" "Exit")

  case "$CHOICE" in
    "Copy Username")
      echo "$USERNAME" | pbcopy
      echo "✅ Username copied to clipboard"
      clear_clipboard_later
      ;;
    "Copy Password")
      echo "$PASSWORD" | pbcopy
      echo "✅ Password copied to clipboard"
      clear_clipboard_later
      ;;
    "Show Both")
      echo "Username: $USERNAME"
      echo "Password: $PASSWORD"
      echo ""
      ;;
    "Select Different Login")
      # Use fzf to select a new login
      SELECTED_ITEM=$(echo "$ITEMS" | jq -r '.[] | select(.type == 1) | "\(.name) | \(.login.username)"' | fzf --height 40% --border --prompt="Select login: ")
      
      if [ -z "$SELECTED_ITEM" ]; then
        echo "No item selected, keeping previous selection"
      else
        # Extract the name from the selection
        ITEM_NAME=$(echo "$SELECTED_ITEM" | cut -d '|' -f 1 | xargs)
        
        # Get the full item details
        ITEM_DETAILS=$(echo "$ITEMS" | jq -r --arg name "$ITEM_NAME" '.[] | select(.name == $name)')
        
        # Get username and password
        USERNAME=$(echo "$ITEM_DETAILS" | jq -r '.login.username')
        PASSWORD=$(echo "$ITEM_DETAILS" | jq -r '.login.password')
      fi
      ;;
    "Exit")
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid option"
      ;;
  esac
  
  echo ""
  echo "Press Enter to continue..."
  read
  clear
done
