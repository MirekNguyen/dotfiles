#!/usr/bin/env bash
#
# Converge this Mac to whatever is committed in this repo.
# Idempotent: run it on a factory-fresh machine or for the hundredth time.
#
#   ./install/setup.sh                 # run every step
#   ./install/setup.sh darwin          # run one step
#   ./install/setup.sh --skip nix      # run everything except one
#   ./install/setup.sh --list          # show the steps
#   ./install/setup.sh --yes           # never prompt
#
. "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

STEPS_DIR="$REPO/install/steps"

# "00-preflight.sh" -> "preflight"
step_name() { local b; b="$(basename "$1" .sh)"; printf '%s' "${b#*-}"; }

all_steps() {
  local f
  for f in "$STEPS_DIR"/[0-9][0-9]-*.sh; do
    [ -e "$f" ] && printf '%s\n' "$f"
  done
}

usage() {
  # Print the header comment block (everything after the shebang up to the
  # first non-comment line), stripped of leading '#'.
  awk 'NR==1 {next} /^#/ {sub(/^# ?/,""); print; next} {exit}' "${BASH_SOURCE[0]}"
  echo "Steps:"
  local f
  for f in $(all_steps); do printf '  %s\n' "$(step_name "$f")"; done
}

only=(); skips=()
while [ $# -gt 0 ]; do
  case "$1" in
    --list|-l) usage; exit 0 ;;
    --help|-h) usage; exit 0 ;;
    --yes|-y)  export ASSUME_YES=1 ;;
    --skip)    [ $# -ge 2 ] || die "--skip needs a step name"; skips+=("$2"); shift ;;
    -*)        die "unknown flag: $1 (try --help)" ;;
    *)         only+=("$1") ;;
  esac
  shift
done

wanted() {
  local name="$1" s
  for s in ${skips+"${skips[@]}"};  do [ "$s" = "$name" ] && return 1; done
  [ ${#only[@]} -eq 0 ] && return 0
  for s in "${only[@]}"; do [ "$s" = "$name" ] && return 0; done
  return 1
}

# Validate names up front so a typo fails immediately instead of silently
# running nothing.
known=""
for f in $(all_steps); do known="$known $(step_name "$f")"; done
for s in ${only+"${only[@]}"} ${skips+"${skips[@]}"}; do
  case " $known " in *" $s "*) ;; *) die "no such step: $s (have:$known)" ;; esac
done

# Keep sudo warm so long builds don't stall on an expired prompt mid-run.
if [ "${ASSUME_YES:-0}" != "1" ] || [ -t 0 ]; then
  sudo -v || die "sudo is required"
fi
while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
sudo_keepalive=$!
trap 'kill "$sudo_keepalive" 2>/dev/null || true' EXIT

start=$SECONDS
for f in $(all_steps); do
  name="$(step_name "$f")"
  wanted "$name" || { skip "step $name"; continue; }
  printf '\n%s[ %s ]%s\n' "$C_BLUE" "$name" "$C_OFF"
  bash "$f" || die "step '$name' failed"
done

printf '\n%sdone in %ss%s\n' "$C_GREEN" "$((SECONDS - start))" "$C_OFF"
