#!/usr/bin/env bash
# Shared helpers + configuration. Sourced by setup.sh and every step.

set -euo pipefail

# --- repo layout -------------------------------------------------------------
: "${REPO:=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
export REPO

# Name of the darwinConfiguration in mac/flake.nix. Deliberately independent of
# the machine's hostname so a new Mac works without renaming it first.
: "${FLAKE_HOST:=mira}"
export FLAKE_HOST
export FLAKE="$REPO/mac#$FLAKE_HOST"

export GIT_REMOTE_SSH="git@github.com:MirekNguyen/dotfiles.git"
export GIT_REMOTE_HTTPS="https://github.com/MirekNguyen/dotfiles.git"

# --- output ------------------------------------------------------------------
if [ -t 1 ]; then
  C_BLUE=$'\033[1;34m'; C_GREEN=$'\033[1;32m'; C_YELLOW=$'\033[1;33m'
  C_RED=$'\033[1;31m';  C_DIM=$'\033[2m';      C_OFF=$'\033[0m'
else
  C_BLUE=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_DIM=''; C_OFF=''
fi

log()  { printf '%s==>%s %s\n'  "$C_BLUE"   "$C_OFF" "$*"; }
ok()   { printf '%s  ok%s %s\n' "$C_GREEN"  "$C_OFF" "$*"; }
skip() { printf '%s  --%s %s\n' "$C_DIM"    "$C_OFF" "$*"; }
warn() { printf '%swarn:%s %s\n' "$C_YELLOW" "$C_OFF" "$*" >&2; }
die()  { printf '%serror:%s %s\n' "$C_RED"  "$C_OFF" "$*" >&2; exit 1; }

# --- guards ------------------------------------------------------------------
require_macos() {
  [ "$(uname -s)" = "Darwin" ] || die "this repo only sets up macOS"
}

is_arm64() { [ "$(uname -m)" = "arm64" ]; }

have() { command -v "$1" >/dev/null 2>&1; }

# Put nix on PATH for the current process if it was installed in this same run
# (or by a previous run in another shell).
load_nix() {
  have nix && return 0
  local profile=/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  # shellcheck disable=SC1090
  [ -e "$profile" ] && . "$profile"
  have nix
}

# `nix` needs flakes for everything we do; the system nix.conf only gets them
# after the first darwin switch, so always pass them explicitly.
NIX_FLAGS=(--extra-experimental-features "nix-command flakes")
export NIX_FLAGS

# nix-homebrew installs into /opt/homebrew (and /usr/local under Rosetta). Those
# are not on PATH in a non-login shell, so add them when we need brew binaries.
load_brew() {
  local p
  for p in /opt/homebrew /usr/local; do
    [ -x "$p/bin/brew" ] && case ":$PATH:" in
      *":$p/bin:"*) ;;
      *) PATH="$p/bin:$PATH" ;;
    esac
  done
  export PATH
  have brew
}

# --- git ---------------------------------------------------------------------
# Returns 0 when GitHub accepts our SSH key. GitHub always exits 1 on a
# successful auth (it refuses shell access), hence the message match.
github_ssh_works() {
  ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new \
      -o ConnectTimeout=5 -T git@github.com 2>&1 |
    grep -q "successfully authenticated"
}

# Rewrite ssh submodule/remote URLs to https when we have no usable key.
git_url_args() {
  if github_ssh_works; then
    printf '%s' ''
  else
    printf '%s' "-c url.https://github.com/.insteadOf=git@github.com:"
  fi
}

confirm() {
  local prompt="$1"
  [ "${ASSUME_YES:-0}" = "1" ] && return 0
  [ -t 0 ] || return 1
  printf '%s [y/N] ' "$prompt"
  local reply; read -r reply
  case "$reply" in [yY]*) return 0 ;; *) return 1 ;; esac
}

# Create a symlink idempotently, refusing to clobber real files.
link() {
  local src="$1" dest="$2"
  if [ ! -e "$src" ]; then skip "$dest (source missing)"; return 0; fi
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    local cur; cur="$(readlink "$dest")"
    if [ "${cur%/}" = "${src%/}" ]; then skip "$dest already linked"; return 0; fi
    rm "$dest"
  elif [ -e "$dest" ]; then
    warn "$dest exists and is not a symlink - leaving it alone"
    return 0
  fi
  ln -s "$src" "$dest"
  ok "linked $dest"
}
