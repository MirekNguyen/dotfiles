#!/usr/bin/env bash
# Keep the machine in step with linux/packages.txt.
#
#   packages.sh install   install every listed package that is missing
#   packages.sh diff      show installed-but-unlisted and listed-but-missing
#
# diff reports unlisted packages only among explicitly installed ones
# (pacman -Qqe), so dependencies pulled in automatically never show up as
# noise; a listed package counts as installed however it got there.
set -euo pipefail

list="$(dirname "$(readlink -f "$0")")/packages.txt"

# Strip comments and blank lines.
wanted() { sed 's/#.*//; s/[[:space:]]//g; /^$/d' "$list" | sort -u; }

case "${1:-}" in
  install)
    # --needed skips what is already installed, so this is safe to re-run.
    mapfile -t pkgs < <(wanted)
    yay -S --needed "${pkgs[@]}"
    ;;
  diff)
    explicit=$(pacman -Qqe | grep -v -- '-debug$' | sort)
    extra=$(comm -13 <(wanted) <(echo "$explicit"))
    missing=$(comm -23 <(wanted) <(pacman -Qq | sort))
    [ -n "$extra" ] && printf 'Installed but not in packages.txt:\n%s\n\n' "$(sed 's/^/  /' <<<"$extra")"
    [ -n "$missing" ] && printf 'In packages.txt but not installed:\n%s\n\n' "$(sed 's/^/  /' <<<"$missing")"
    [ -z "$extra$missing" ] && echo "packages.txt matches the system."
    [ -z "$extra$missing" ]
    ;;
  *)
    sed -n '2,6s/^# \{0,1\}//p' "$0" >&2
    exit 2
    ;;
esac
