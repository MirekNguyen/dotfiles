#!/usr/bin/env bash
# rofi script mode: web shortcuts.
# Edit linux/rofi/bookmarks.tsv to change the list. Format is: Name<TAB>URL[<TAB>Icon]
# Wired up by linux/scripts/rofi-toggle.sh as the "web" modi.

set -uo pipefail

BOOKMARKS="$HOME/.config/dotfiles/linux/rofi/bookmarks.tsv"

# Selection pass: rofi re-invokes us with the entry as $1 and its info as
# $ROFI_INFO. Hand the URL to the desktop's default browser and get out of the
# way -- setsid detaches it so the browser does not die with rofi.
if [ -n "${ROFI_INFO:-}" ]; then
  setsid xdg-open "$ROFI_INFO" >/dev/null 2>&1 &
  exit 0
fi

[ -r "$BOOKMARKS" ] || exit 0

# Default icon for entries that do not name one. These all open in the browser,
# so its icon is the honest choice -- and unlike Adwaita's web-browser-symbolic
# it is full colour, so the rows match the app icons drun renders beside them.
DEFAULT_ICON="helium-browser"

# Listing pass. After the NUL, rofi reads \x1f-separated key/value pairs, so
# this attaches both the icon and the URL invisibly to each row.
while IFS=$'\t' read -r name url icon; do
  case "$name" in
    ''|\#*) continue ;;
  esac
  [ -n "${url:-}" ] || continue
  icon="${icon:-$DEFAULT_ICON}"
  # Relative paths (icons/foo.png) live in the wallpapers repo.
  case "$icon" in
    /*) ;;
    */*) icon="$HOME/Pictures/wallpapers/icons/rofi/${icon#icons/}" ;;
  esac
  printf '%s\0icon\x1f%s\x1finfo\x1f%s\n' "$name" "$icon" "$url"
done < "$BOOKMARKS"
