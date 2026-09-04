#!/usr/bin/env bash
# Report on anything that still needs a human.
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

load_brew || true

pending=0
note() { printf '  %s*%s %s\n' "$C_YELLOW" "$C_OFF" "$*"; pending=1; }

echo
log "post-install checks"

# --- Mac App Store -----------------------------------------------------------
# homebrew.masApps needs an App Store session; when signed out the app simply
# never appears. mas 7 removed `mas account`, so verify by result instead:
# every ID declared in the flake must show up in `mas list`.
if have mas; then
  missing=0
  installed="$(mas list 2>/dev/null | awk '{print $1}')"
  while read -r id; do
    [ -n "$id" ] || continue
    if printf '%s\n' "$installed" | grep -qx "$id"; then continue; fi
    note "Mac App Store app $id is declared but not installed"
    missing=1
  done < <(sed -n '/masApps = {/,/};/p' "$REPO/mac/flake.nix" |
           sed -n 's/.*= \([0-9][0-9]*\);.*/\1/p')
  if [ "$missing" -eq 0 ]; then
    ok "Mac App Store apps installed"
  else
    note "sign in to the App Store, then re-run: ./install/setup.sh darwin"
  fi
fi

# --- login shell -------------------------------------------------------------
fish_path="$(command -v fish || true)"
if [ -n "$fish_path" ] && [ "$SHELL" != "$fish_path" ]; then
  note "login shell is $SHELL; to switch: chsh -s $fish_path (add it to /etc/shells first)"
elif [ -n "$fish_path" ]; then
  ok "login shell is fish"
fi

# --- fisher plugins ----------------------------------------------------------
if [ -n "$fish_path" ] && [ -f "$HOME/.config/fish/fish_plugins" ]; then
  if [ -d "$HOME/.config/fish/functions" ]; then
    ok "fish plugins installed"
  else
    note "install fish plugins: fish -c 'fisher update'"
  fi
fi

# --- manual macOS settings ---------------------------------------------------
note "manual System Settings remain - see mac/system-settings.md:"
printf '      keyboard modifier remaps, keyboard shortcuts, input sources, wallpaper\n'

echo
if [ "$pending" -eq 1 ]; then
  printf '%sSetup finished with manual follow-ups above.%s\n' "$C_YELLOW" "$C_OFF"
else
  printf '%sSetup finished. Nothing left to do.%s\n' "$C_GREEN" "$C_OFF"
fi
