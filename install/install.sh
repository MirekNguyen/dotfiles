#!/usr/bin/env bash
#
# Bootstrap entry point for a brand new Mac. Safe to curl-pipe, safe to re-run.
#
#   curl -fsSL https://raw.githubusercontent.com/MirekNguyen/dotfiles/main/install/install.sh | bash
#
# Only does what must happen *before* the repo exists locally:
#   command line tools -> clone (or pull) -> hand off to install/setup.sh
#
set -euo pipefail

REPO="${DOTFILES:-$HOME/.config/dotfiles}"
REMOTE_SSH="git@github.com:MirekNguyen/dotfiles.git"
REMOTE_HTTPS="https://github.com/MirekNguyen/dotfiles.git"

log() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(uname -s)" = "Darwin" ] || die "macOS only"

# A factory-fresh Mac has no git at all, so this cannot wait for the preflight
# step inside the repo.
if ! xcode-select -p >/dev/null 2>&1; then
  log "installing Xcode Command Line Tools (accept the dialog)"
  xcode-select --install 2>/dev/null || true
  printf '    waiting'
  until xcode-select -p >/dev/null 2>&1; do printf '.'; sleep 5; done
  printf '\n'
fi

if [ -d "$REPO/.git" ]; then
  log "updating $REPO"
  git -C "$REPO" pull --ff-only ||
    log "pull skipped (local changes or diverged branch) - continuing"
else
  log "cloning into $REPO"
  mkdir -p "$(dirname "$REPO")"
  # ssh first so an existing key keeps a pushable remote; https is the fresh-Mac path.
  git clone "$REMOTE_SSH" "$REPO" 2>/dev/null ||
    git clone "$REMOTE_HTTPS" "$REPO" ||
    die "clone failed"
fi

exec bash "$REPO/install/setup.sh" "$@"
