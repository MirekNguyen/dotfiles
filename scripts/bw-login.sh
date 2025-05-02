#!/usr/bin/env bash

echo "Fetching items from Bitwarden..."
ITEMS=$(bw list items)

SELECTED_ITEM=$(echo "$ITEMS" | jq -r '.[] | select(.type == 1) | "\(.name) | \(.login.username)"' | fzf --height 40% --border --prompt="Select login: ")

if [ -z "$SELECTED_ITEM" ]; then
  echo "No item selected"
  exit 0
fi

ITEM_NAME=$(echo "$SELECTED_ITEM" | cut -d '|' -f 1 | xargs)

ITEM_DETAILS=$(echo "$ITEMS" | jq -r --arg name "$ITEM_NAME" '.[] | select(.name == $name)')

USERNAME=$(echo "$ITEM_DETAILS" | jq -r '.login.username')
PASSWORD=$(echo "$ITEM_DETAILS" | jq -r '.login.password')

clear_clipboard_later() {
  if [ ! -z "$CLIPBOARD_PID" ] && ps -p $CLIPBOARD_PID > /dev/null; then
    kill $CLIPBOARD_PID 2>/dev/null
  fi
  
  (sleep 30 && echo "" | pbcopy) &
  CLIPBOARD_PID=$!
  echo "Clipboard will be cleared in 30 seconds"
}

while true; do
  echo "Selected: $ITEM_NAME"
  echo "-------------------"
  
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
      SELECTED_ITEM=$(echo "$ITEMS" | jq -r '.[] | select(.type == 1) | "\(.name) | \(.login.username)"' | fzf --height 40% --border --prompt="Select login: ")
      
      if [ -z "$SELECTED_ITEM" ]; then
        echo "No item selected, keeping previous selection"
      else
        ITEM_NAME=$(echo "$SELECTED_ITEM" | cut -d '|' -f 1 | xargs)
        
        ITEM_DETAILS=$(echo "$ITEMS" | jq -r --arg name "$ITEM_NAME" '.[] | select(.name == $name)')
        
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
