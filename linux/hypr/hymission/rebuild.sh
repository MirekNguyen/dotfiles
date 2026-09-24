#!/usr/bin/env bash
# Rebuild the hymission plugin (Mission Control on F3) and reload it.
#
#   rebuild.sh [--pull]
#
# Run this after any pacman update that touches hyprland. Plugins are compiled
# against Hyprland's headers, so after an update the old build refuses to load:
# Hyprland itself keeps working, but F3 stops doing anything.
#
# --pull also fetches the latest hymission source first, which is usually what
# you want when a new Hyprland release needs plugin-side fixes.
#
# Build steps are the ones from hymission's own hyprpm.toml.

set -euo pipefail

# Cloned next to this script (gitignored), so a fresh machine only needs to run
# this once to get the plugin.
SRC="$(dirname "$(readlink -f "$0")")/build"
SO="$SRC/build-cmake/libhymission.so"

if [ ! -d "$SRC/.git" ]; then
  git clone https://github.com/gfhdhytghd/hymission.git "$SRC"
elif [ "${1:-}" = "--pull" ]; then
  git -C "$SRC" pull --ff-only
fi

cd "$SRC"
cmake -E rm -f build-cmake/CMakeCache.txt
cmake -DCMAKE_BUILD_TYPE=Release -B build-cmake >/dev/null
cmake --build build-cmake -j"$(nproc)"
install -Dm755 build-cmake/hymission-search-input "$HOME/.local/bin/hymission-search-input"

# Swap the running copy for the new one. "plugin not loaded" is expected when
# the old build had already failed to load after the update.
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  hyprctl plugin unload "$SO" >/dev/null 2>&1 || true
  hyprctl plugin load "$SO"
  hyprctl plugin list | grep -A2 hymission
fi
