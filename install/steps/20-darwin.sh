#!/usr/bin/env bash
# Build and activate the nix-darwin system: packages, Homebrew, casks, Mac App
# Store apps, fonts and macOS defaults.
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_macos
load_nix || die "nix is not available - run the 'nix' step first"

# --- clear /etc conflicts ----------------------------------------------------
# nix-darwin writes /etc/zshrc, /etc/bashrc and /etc/zprofile, and aborts rather
# than clobber a file it did not create. Move Apple's originals aside once.
for f in zshrc zshenv zprofile bashrc bash.bashrc; do
  src="/etc/$f"
  [ -e "$src" ] || continue
  [ -e "$src.before-nix-darwin" ] && continue
  grep -q "nix-darwin" "$src" 2>/dev/null && continue
  log "backing up $src -> $src.before-nix-darwin"
  sudo mv "$src" "$src.before-nix-darwin"
done

# --- build -------------------------------------------------------------------
# Build first so a broken flake fails before we ask for sudo or touch the system.
log "building $FLAKE"
system="$(nix "${NIX_FLAGS[@]}" build "$REPO/mac#darwinConfigurations.$FLAKE_HOST.system" \
  --no-link --print-out-paths)"
ok "built $system"

# --- activate ----------------------------------------------------------------
# Use the darwin-rebuild from the build we just made rather than
# `nix run nix-darwin`, so activation always matches mac/flake.lock.
if have darwin-rebuild; then
  rebuild=(darwin-rebuild)
else
  log "bootstrapping: no darwin-rebuild on PATH yet"
  rebuild=("$system/sw/bin/darwin-rebuild")
fi

log "activating (sudo)"
sudo "${rebuild[@]}" switch --flake "$FLAKE"
ok "system activated"
