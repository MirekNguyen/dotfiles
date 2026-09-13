#!/usr/bin/env bash
#
# Read-only drift report: "is this machine still what the repos say it is?"
#
#   install/status.sh          full check (decrypts secrets to compare contents)
#   install/status.sh --quick  stat/git only, fast enough for a shell prompt
#
# Exit 0 when everything is in sync, 1 when something drifted.
# Never writes anything, never asks for sudo.
#
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

QUICK=0
[ "${1:-}" = "--quick" ] && QUICK=1

SECRETS_REPO="${SECRETS_REPO:-$HOME/.config/dotfiles-secrets}"
export SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}"

drift=0
say() { printf '  %s*%s %s\n' "$C_YELLOW" "$C_OFF" "$*"; drift=1; }

# --- git repos ---------------------------------------------------------------
check_repo() {
  local dir="$1" name="$2" n
  [ -d "$dir/.git" ] || { say "$name: not cloned"; return; }

  n=$(git -C "$dir" status --porcelain | grep -c . || true)
  if [ "$n" -gt 0 ]; then
    say "$name: $n uncommitted change(s)  -> git -C $dir status"
  fi

  # @{u} fails when there is no upstream; that is not drift.
  if git -C "$dir" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
    n=$(git -C "$dir" rev-list --count '@{u}..HEAD' 2>/dev/null || echo 0)
    if [ "$n" -gt 0 ]; then
      say "$name: $n unpushed commit(s)  -> git -C $dir push"
    fi
  fi
}

check_repo "$REPO" "dotfiles"
check_repo "$SECRETS_REPO" "secrets"

# --- submodules --------------------------------------------------------------
# `git submodule status` costs ~100ms, and a dirty submodule already shows up in
# `git status --porcelain` above, so only run it in full mode.
if [ "$QUICK" -eq 0 ]; then
  while read -r state sha path _; do
    if [ "${state:0:1}" = "+" ]; then
      say "submodule $path ahead of pinned commit  -> git -C $REPO add $path"
    fi
  done < <(git -C "$REPO" submodule status 2>/dev/null | sed 's/^\(.\)/\1 /')
fi

# --- secrets: edited locally but not re-encrypted ----------------------------
# 25-secrets.sh stamps each decrypted file with its .enc mtime, so "plaintext
# newer than .enc" means it was edited on this machine since the last sync.
if [ -d "$SECRETS_REPO" ]; then
  while IFS= read -r enc; do
    rel="${enc#*/home/}"
    case "$rel" in *.tar.enc) continue ;; esac   # directories: full mode only
    dest="$HOME/${rel%.enc}"
    [ -f "$dest" ] || { say "missing locally: ~/${rel%.enc}  -> setup.sh secrets"; continue; }
    if [ "$dest" -nt "$enc" ]; then
      say "edited since last sync: ~/${rel%.enc}  -> secret add ${rel%.enc}"
    fi
  done < <(find "$SECRETS_REPO"/*/home -type f -name '*.enc' 2>/dev/null)

  # Files sitting in ~/.local/secrets that nothing is backing up.
  while IFS= read -r f; do
    rel="${f#$HOME/}"
    if ! ls "$SECRETS_REPO"/*/home/"$rel".enc >/dev/null 2>&1; then
      say "not backed up: ~/$rel  -> secret add $rel"
    fi
  done < <(find "$HOME/.local/secrets" -maxdepth 1 -type f ! -name '.*' 2>/dev/null)
fi

# --- crontab -----------------------------------------------------------------
if [ -f "$HOME/.config/cron/crontab" ]; then
  if [ "$(crontab -l 2>/dev/null)" != "$(cat "$HOME/.config/cron/crontab")" ]; then
    say "crontab differs from the repo  -> setup.sh cron"
  fi
fi

# --- full-only checks --------------------------------------------------------
if [ "$QUICK" -eq 0 ]; then
  # Broken or missing stow links.
  while IFS= read -r item; do
    dest="$HOME/.config/$(basename "$item")"
    [ -e "$dest" ] || { say "not linked: ~/.config/$(basename "$item")  -> setup.sh dotfiles"; continue; }
    if [ ! -L "$dest" ] && [ ! -d "$dest" ]; then say "not a symlink: $dest"; fi
  done < <(find "$REPO/config" -maxdepth 1 -mindepth 1)

  # Content-level secret comparison (slow: decrypts everything).
  if have sops && [ -f "$SOPS_AGE_KEY_FILE" ]; then
    while IFS= read -r enc; do
      rel="${enc#*/home/}"
      case "$rel" in *.tar.enc) continue ;; esac
      dest="$HOME/${rel%.enc}"
      [ -f "$dest" ] || continue
      it=binary; grep -q '^sops_version=' "$enc" && it=dotenv
      if ! cmp -s <(sops --input-type "$it" --output-type "$it" -d "$enc" 2>/dev/null) "$dest"; then
        say "content differs: ~/${rel%.enc}  -> secret add ${rel%.enc}"
      fi
    done < <(find "$SECRETS_REPO"/*/home -type f -name '*.enc' 2>/dev/null)
  fi

  # Uncommitted nix changes mean `nix-rebuild` is running unversioned config.
  if ! git -C "$REPO" diff --quiet -- mac/ 2>/dev/null; then
    say "mac/flake.nix has uncommitted changes"
  fi
fi

if [ "$drift" -eq 0 ]; then
  [ "$QUICK" -eq 1 ] || ok "everything in sync"
  exit 0
fi
exit 1
