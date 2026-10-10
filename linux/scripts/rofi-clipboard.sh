#!/usr/bin/env bash
# rofi script mode: clipboard history, with thumbnails for images.
# A tab in the launcher, see rofi-toggle.sh.
#
#   Enter         copy the entry back to the clipboard
#   Shift+Enter   Quick Look: open an image full size in Loupe

set -uo pipefail

thumbs="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist/thumbs"

# Selection pass. rofi re-runs the script with the cliphist id in ROFI_INFO;
# printing nothing closes rofi.
if [ -n "${ROFI_INFO:-}" ]; then
  if [ "${ROFI_RETV:-1}" = 10 ]; then
    img=$(ls "$thumbs/$ROFI_INFO".* 2>/dev/null | head -1)
    if [ -z "$img" ]; then
      img="$thumbs/$ROFI_INFO.png"
      cliphist decode "$ROFI_INFO" >"$img"
    fi
    setsid loupe "$img" >/dev/null 2>&1 &
    exit 0
  fi

  data=$(mktemp); trap 'rm -f "$data"' EXIT
  cliphist decode "$ROFI_INFO" >"$data" 2>/dev/null

  # cliphist keeps only the text form of a file copy (the paths), so restoring it
  # verbatim pastes a path string. If every line is an existing file, offer it
  # back as text/uri-list instead, which is what Nautilus and LocalSend read as
  # "these files".
  uris=$(python3 - "$data" <<'PY'
import sys, pathlib, urllib.parse
try:
    lines = [l for l in open(sys.argv[1], encoding="utf-8").read().splitlines() if l]
except (UnicodeDecodeError, OSError):
    sys.exit(1)
paths = [urllib.parse.unquote(l[7:]) if l.startswith("file://") else l for l in lines]
if not paths or not all(p.startswith("/") and pathlib.Path(p).exists() for p in paths):
    sys.exit(1)
print("".join(pathlib.Path(p).as_uri() + "\r\n" for p in paths), end="")
PY
)
  if [ -n "$uris" ]; then
    printf '%s' "$uris" | wl-copy --type text/uri-list
  else
    wl-copy <"$data"
  fi
  exit 0
fi

mkdir -p "$thumbs"

# Drop thumbnails whose history entry is gone (cliphist caps at 750 items).
ids=$(cliphist list | cut -f1)
for f in "$thumbs"/*; do
  [ -e "$f" ] || continue
  id=${f##*/}; id=${id%%.*}
  grep -qx "$id" <<<"$ids" || rm -f "$f"
done

printf '\0use-hot-keys\x1ftrue\n'

cliphist list | while IFS=$'\t' read -r id preview; do
  icon=
  if [[ $preview =~ ^\[\[\ binary\ data\ .*\ (png|jpe?g|gif|webp|bmp)\  ]]; then
    icon="$thumbs/$id.${BASH_REMATCH[1]}"
    [ -s "$icon" ] || cliphist decode "$id" >"$icon" 2>/dev/null
    preview=${preview#\[\[ binary data }; preview="Image  ${preview% \]\]}"
  elif [[ $preview == /* || $preview == file:///* ]]; then
    first=$(cliphist decode "$id" 2>/dev/null | head -1)
    first=${first#file://}
    first=$(printf '%b' "${first//%/\\x}")
    if [[ -f $first && ${first,,} =~ \.(png|jpe?g|gif|webp)$ ]]; then
      icon="$thumbs/$id.${first##*.}"
      [ -e "$icon" ] || ln -s "$first" "$icon"
    fi
  fi
  printf '%s\0info\x1f%s\x1ficon\x1f%s\n' "$preview" "$id" "$icon"
done
