#!/usr/bin/env bash
# Decrypt the private dotfiles-secrets repo into $HOME.
#
# Ordering: after `darwin` (which installs sops/age) and before `dotfiles`
# (which symlinks work.conf/work-vpn and checks opencode's {env:...} keys).
#
# Layout is convention-driven - there is no list to maintain here:
#
#   <tier>/home/<path>.enc      ->  $HOME/<path>        (mode 0600)
#   <tier>/home/<dir>.tar.enc   ->  extracted into $HOME/<dirname of dir>
#
# where <tier> is `personal` or `work`. Add a file with `scripts/secret add`.
#
# Bootstrap chain on a new machine:
#   password manager -> age key at $SOPS_AGE_KEY_FILE -> this step -> everything else
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_macos
load_nix >/dev/null 2>&1 || true

SECRETS_REPO="${SECRETS_REPO:-$HOME/.config/dotfiles-secrets}"
SECRETS_REMOTE_SSH="git@github.com:MirekNguyen/dotfiles-secrets.git"
SECRETS_REMOTE_HTTPS="https://github.com/MirekNguyen/dotfiles-secrets.git"
AGE_KEY="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"
export SOPS_AGE_KEY_FILE="$AGE_KEY"

have sops || die "sops not found - run the 'darwin' step first"

# --- the one secret a human must carry ---------------------------------------
if [ ! -f "$AGE_KEY" ]; then
  warn "no age key at $AGE_KEY"
  warn "restore it from Proton Pass (item: 'age key - dotfiles-secrets'),"
  warn "then re-run: ./install/setup.sh secrets"
  warn "skipping - ~/.local/secrets will not be populated"
  exit 0
fi
chmod 700 "$(dirname "$AGE_KEY")" 2>/dev/null || true
chmod 600 "$AGE_KEY"
ok "age key present ($(age-keygen -y "$AGE_KEY" 2>/dev/null || echo unreadable))"

# --- private repo ------------------------------------------------------------
if [ -d "$SECRETS_REPO/.git" ]; then
  git -C "$SECRETS_REPO" pull --ff-only --quiet 2>/dev/null ||
    warn "could not fast-forward $SECRETS_REPO - using the local copy"
  ok "secrets repo up to date"
else
  log "cloning dotfiles-secrets"
  git clone --quiet "$SECRETS_REMOTE_SSH" "$SECRETS_REPO" 2>/dev/null ||
    git clone --quiet "$SECRETS_REMOTE_HTTPS" "$SECRETS_REPO" ||
    die "could not clone the secrets repo"
  ok "cloned into $SECRETS_REPO"
fi

# sops guesses the format from the file extension, and `.enc` tells it nothing.
# dotenv-encrypted files carry flat `sops_version=` keys; everything else is the
# JSON envelope we get from binary mode.
input_type() {
  grep -q '^sops_version=' "$1" && printf 'dotenv' || printf 'binary'
}

restored=0 failed=0

while IFS= read -r src; do
  # shellcheck disable=SC2034
  rel="${src#*/home/}"                       # strip "<tier>/home/"
  it="$(input_type "$src")"
  tmp="$(mktemp)"

  if ! sops --input-type "$it" --output-type "$it" -d "$src" > "$tmp" 2>/dev/null; then
    rm -f "$tmp"; warn "failed to decrypt ${src#$SECRETS_REPO/}"; failed=1; continue
  fi

  case "$rel" in
    *.tar.enc)
      # A directory shipped as a tarball, to keep member names out of the repo.
      dest_dir="$HOME/$(dirname "${rel%.tar.enc}")"
      target="$HOME/${rel%.tar.enc}"
      stage="$(mktemp -d)"
      if ! tar -xzf "$tmp" -C "$stage" 2>/dev/null; then
        warn "failed to extract ${src#$SECRETS_REPO/}"; failed=1
      elif [ -d "$target" ] && diff -rq "$stage/$(basename "$target")" "$target" >/dev/null 2>&1; then
        :                                     # already current
      else
        mkdir -p "$dest_dir"
        rm -rf "$target"
        mv "$stage/$(basename "$target")" "$dest_dir/"
        restored=$((restored + 1))
      fi
      rm -rf "$stage" "$tmp"
      ;;
    *)
      dest="$HOME/${rel%.enc}"
      mkdir -p "$(dirname "$dest")"
      if [ -f "$dest" ] && cmp -s "$tmp" "$dest"; then
        rm -f "$tmp"                          # unchanged: keep mtime stable
      else
        mv "$tmp" "$dest"
        restored=$((restored + 1))
      fi
      # Stamp the plaintext with the .enc file's mtime. That makes
      # "plaintext newer than .enc" an exact, stat-cheap drift signal, which is
      # what install/status.sh uses on every shell prompt.
      touch -r "$src" "$dest"
      case "$dest" in
        *.pub) chmod 644 "$dest" ;;
        *)     chmod 600 "$dest" ;;
      esac
      ;;
  esac
done < <(find "$SECRETS_REPO"/*/home -type f -name '*.enc' 2>/dev/null | sort)

# Directories that hold secrets should never be group/world readable.
chmod 700 "$HOME/.ssh" "$HOME/.local/secrets" 2>/dev/null || true
find "$HOME/.local/secrets" -type d -exec chmod 700 {} + 2>/dev/null || true

if [ "$restored" -eq 0 ]; then
  ok "secrets already current"
else
  ok "restored $restored item(s)"
fi
[ "$failed" -eq 0 ] || die "some secrets could not be decrypted"
