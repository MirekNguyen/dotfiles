#!/usr/bin/env bash
# Things that must exist before Nix or git can do anything useful.
# Safe to re-run: every check is a no-op once satisfied.
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_macos

# --- Xcode Command Line Tools ------------------------------------------------
# A factory-fresh Mac has no `git`, no `cc`, and Nix's installer needs both.
if xcode-select -p >/dev/null 2>&1; then
  ok "command line tools present ($(xcode-select -p))"
else
  log "installing Xcode Command Line Tools"
  # Triggers a GUI dialog; there is no supported headless path.
  xcode-select --install 2>/dev/null || true
  printf '%s' "    waiting for the installer to finish"
  until xcode-select -p >/dev/null 2>&1; do
    printf '.'
    sleep 5
  done
  printf '\n'
  ok "command line tools installed"
fi

# --- Rosetta 2 ---------------------------------------------------------------
# nix-homebrew is configured with enableRosetta = true, which manages an
# x86_64 Homebrew prefix under /usr/local and needs Rosetta to run it.
if is_arm64; then
  if /usr/bin/pgrep -q oahd || [ -d /Library/Apple/usr/share/rosetta ]; then
    ok "rosetta 2 present"
  else
    log "installing rosetta 2"
    softwareupdate --install-rosetta --agree-to-license
    ok "rosetta 2 installed"
  fi
fi

# --- username ----------------------------------------------------------------
# mac/flake.nix pins the user that owns the Homebrew prefix and the user-level
# defaults. A different $USER silently produces a broken activation.
flake_user="$(sed -n 's/^[[:space:]]*username = "\(.*\)";[[:space:]]*$/\1/p' \
  "$REPO/mac/flake.nix" | head -1)"

if [ -z "$flake_user" ]; then
  warn "could not read 'username' from mac/flake.nix - skipping check"
elif [ "$flake_user" = "$(id -un)" ]; then
  ok "username matches flake ($flake_user)"
else
  warn "you are '$(id -un)' but mac/flake.nix declares username = \"$flake_user\""
  warn "edit the 'username' binding in mac/flake.nix before continuing"
  confirm "  continue anyway?" || die "aborted"
fi
