#!/usr/bin/env bash
#
# DESTRUCTIVE variant of install.sh, for a freshly imaged Mac.
#
# Identical to the normal flow except that pre-existing files in ~/.config which
# would block stow are deleted instead of reported. Everything else (nix,
# homebrew, macOS defaults) is already idempotent and needs no special casing.
#
set -euo pipefail

REPO="${DOTFILES:-$HOME/.config/dotfiles}"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

cat <<EOF
This will DELETE any real file or directory in ~/.config whose name matches an
entry in the repo's config/ directory. Only do this on a fresh macOS install.
EOF
printf 'Continue? [y/N] '
read -r reply
case "$reply" in [yY]*) ;; *) echo "aborted"; exit 1 ;; esac

[ -d "$REPO/.git" ] || die "$REPO not cloned yet - run install/install.sh first"

log "clearing conflicting entries in ~/.config"
for name in $(ls -A "$REPO/config"); do
  target="$HOME/.config/$name"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    rm -rf "$target"
    log "removed $target"
  fi
done

exec bash "$REPO/install/setup.sh" "$@"
