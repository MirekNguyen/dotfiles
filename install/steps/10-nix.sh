#!/usr/bin/env bash
# Install Nix if absent.
#
# Deliberately the *official* multi-user installer, not Determinate: mac/flake.nix
# sets nix.settings.*, which requires nix-darwin to own /etc/nix/nix.conf. The
# Determinate installer keeps ownership of that file and the two fight.
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_macos

if load_nix; then
  ok "nix present ($(nix --version))"
  return 0 2>/dev/null || exit 0
fi

if [ -d /nix ]; then
  die "/nix exists but 'nix' is not on PATH - open a new shell, or repair the install"
fi

log "installing nix (official multi-user installer)"
curl --proto '=https' --tlsv1.2 -fsSL https://nixos.org/nix/install |
  sh -s -- --daemon --yes

load_nix || die "nix installed but not on PATH - open a new shell and re-run"
ok "nix installed ($(nix --version))"
