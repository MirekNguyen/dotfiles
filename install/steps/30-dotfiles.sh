#!/usr/bin/env bash
# Link the tracked dotfiles into place.
# Runs after the darwin step so `stow` is already installed.
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_macos

# --- submodules --------------------------------------------------------------
# .gitmodules uses an ssh URL; on a fresh Mac there is no key yet, so rewrite to
# https for this invocation only (nothing is written to .git/config).
#
# Only *initialise* submodules that are missing. A plain `submodule update` would
# hard-reset an already-checked-out submodule to the commit pinned in the parent,
# silently discarding work you have committed inside config/nvim but not yet
# recorded here. On a fresh clone there is nothing to lose; on a working machine
# there is.
log "checking submodules"
# shellcheck disable=SC2046
git $(git_url_args) -C "$REPO" submodule sync --quiet --recursive

while read -r state sha path _; do
  case "$state" in
    -*)  # not initialised
      log "initialising submodule $path"
      # shellcheck disable=SC2046
      git $(git_url_args) -C "$REPO" submodule update --init --recursive -- "$path"
      ok "$path initialised"
      ;;
    +*)  # checked out at a different commit than this repo pins
      warn "submodule $path is at ${sha#+} but this repo pins a different commit"
      warn "  commit it here with: git -C $REPO add $path"
      ;;
    *)
      skip "$path up to date"
      ;;
  esac
done < <(git -C "$REPO" submodule status --recursive |
         sed 's/^\(.\)/\1 /')

# --- stow --------------------------------------------------------------------
if have stow; then
  STOW=(stow)
else
  load_nix || die "neither stow nor nix available"
  STOW=(nix "${NIX_FLAGS[@]}" run nixpkgs#stow --)
fi

mkdir -p "$HOME/.config"

log "linking config/ into ~/.config"
# --restow deletes stale links first, so files renamed or removed from the repo
# do not leave dangling symlinks behind.
if ! "${STOW[@]}" --restow --dir "$REPO" --target "$HOME/.config" config; then
  warn "stow reported conflicts: real files in ~/.config are shadowing the repo"
  warn "inspect them, then re-run - or use --adopt/clean-install to overwrite"
  exit 1
fi
ok "config/ linked"

# --- extra symlinks ----------------------------------------------------------
link "$HOME/Library/Mobile Documents/com~apple~CloudDocs" "$HOME/.local/cloud"
