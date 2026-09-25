#!/usr/bin/env bash
# Clipboard history in rofi, with thumbnails for images.

set -uo pipefail

command -v cliphist >/dev/null 2>&1 || exit 0

thumbs="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist/thumbs"
mkdir -p "$thumbs"

# Drop thumbnails whose history entry is gone (cliphist caps at 750 items).
ids=$(cliphist list | cut -f1)
for f in "$thumbs"/*; do
  [ -e "$f" ] || continue
  id=${f##*/}; id=${id%%.*}
  grep -qx "$id" <<<"$ids" || rm -f "$f"
done

list() {
  cliphist list | while IFS=$'\t' read -r id preview; do
    if [[ $preview =~ ^\[\[\ binary\ data\ .*\ (png|jpe?g|gif|webp|bmp)\  ]]; then
      ext=${BASH_REMATCH[1]}
      icon="$thumbs/$id.$ext"
      [ -s "$icon" ] || cliphist decode "$id" >"$icon" 2>/dev/null
      label=${preview#\[\[ binary data }; label="Image  ${label% \]\]}"
      printf '%s\t%s\0icon\x1f%s\n' "$id" "$label" "$icon"
    elif [[ $preview == /* || $preview == file:///* ]]; then
      first=$(cliphist decode "$id" 2>/dev/null | head -1)
      first=${first#file://}
      first=$(printf '%b' "${first//%/\\x}")
      if [[ -f $first && ${first,,} =~ \.(png|jpe?g|gif|webp)$ ]]; then
        printf '%s\t%s\0icon\x1f%s\n' "$id" "$preview" "$first"
      else
        printf '%s\t%s\n' "$id" "$preview"
      fi
    else
      printf '%s\t%s\n' "$id" "$preview"
    fi
  done
}

sel=$(list |
  rofi -dmenu -i \
    -p "Clipboard" \
    -show-icons \
    -theme-str 'listview { require-input: false; lines: 8; }' \
    -theme-str 'element-icon { size: 56px; }' \
    -display-columns 2)

[ -n "$sel" ] || exit 0

data=$(mktemp); trap 'rm -f "$data"' EXIT
printf '%s' "$sel" | cliphist decode >"$data" 2>/dev/null

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
