#!/usr/bin/env bash

MAX_TABS=6
CURRENT_TABS="$(kitty @ ls | jq '.[].tabs[].windows | length' | wc -l)"
if [ "$CURRENT_TABS" -lt "$MAX_TABS" ]; then
    kitty @ launch --type=tab
else
    echo "Maximum number of tabs ($MAX_TABS) reached."
fi
