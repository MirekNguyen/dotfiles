#!/usr/bin/env bash
# Install the tracked crontab.
#
# Idempotent: the crontab is only replaced when it differs from the repo copy,
# so re-running does not churn cron's state or reset job schedules.
. "$(dirname "${BASH_SOURCE[0]}")/../lib/common.sh"

require_macos

src="$HOME/.config/cron/crontab"

if [ ! -f "$src" ]; then
  skip "no crontab at $src (run the dotfiles step first)"
  exit 0
fi

# `crontab -l` exits non-zero when no crontab exists yet.
current="$(crontab -l 2>/dev/null || true)"

if [ "$current" = "$(cat "$src")" ]; then
  ok "crontab already up to date"
  exit 0
fi

log "installing crontab from $src"
if crontab "$src"; then
  ok "crontab installed ($(crontab -l | grep -cvE '^\s*(#|$)') job(s))"
else
  # cron needs Full Disk Access on modern macOS to run jobs touching $HOME.
  warn "could not install crontab"
  warn "System Settings > Privacy & Security > Full Disk Access may need 'cron'"
  exit 1
fi
