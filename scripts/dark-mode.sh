#!/usr/bin/env bash

if [ -n "$1" ]; then
  choice="$1"
else
  choice="$(gum choose "dark" "light")"
fi

if [ "$choice" = "light" ]; then
  kitty @ kitten themes --reload-in=all 'Gruvbox Material Light Soft';
  osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false';
elif [ "$choice" = "dark" ]; then
  kitty @ kitten themes --reload-in=all 'Gruvbox Material Dark Medium';
  osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true';
fi
