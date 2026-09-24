#!/usr/bin/env bash
set -uo pipefail

# How long to wait before escalating to SIGTERM. Long enough to answer an
# "unsaved changes" prompt.
GRACE=5

win_addrs() { # $1 = pid; prints one window address per line
  hyprctl clients -j 2>/dev/null | python3 -c '
import json, sys
pid = int(sys.argv[1])
try:
    clients = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for c in clients:
    if c.get("pid") == pid:
        print(c["address"])
' "$1"
}

pid=$(hyprctl activewindow -j 2>/dev/null | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
p = d.get("pid") or 0
print(p if p > 0 else "")
')

[ -n "${pid:-}" ] || exit 0

# Close every window owned by that process. This is an ordinary close request,
# so apps can still refuse it or raise an "unsaved changes" dialog.
while read -r addr; do
  [ -n "$addr" ] || continue
  hyprctl dispatch "hl.dsp.window.close({ window = \"address:$addr\" })" >/dev/null 2>&1
done < <(win_addrs "$pid")

# Tray-resident apps (Spotify, Steam) keep running with no windows left, so the
# close request alone does not quit them. Escalate -- but only when the app has
# actually given up its windows. If windows remain, the close was refused or the
# user cancelled a save prompt, and killing it anyway would discard their work.
(
  sleep "$GRACE"
  kill -0 "$pid" 2>/dev/null || exit 0
  [ -z "$(win_addrs "$pid")" ] && kill -TERM "$pid" 2>/dev/null
) >/dev/null 2>&1 &

exit 0
