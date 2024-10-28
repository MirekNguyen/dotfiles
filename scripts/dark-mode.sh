#!/usr/bin/env bash

choice="$(gum choose "dark" "light")"

if [ "$choice" = "light" ]; then
  kitty +kitten themes --reload-in=all 'Gruvbox Material Light Soft' &&
  osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false'
else
  kitty +kitten themes --reload-in=all 'Gruvbox Material Dark Medium' &&
  osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'
fi

