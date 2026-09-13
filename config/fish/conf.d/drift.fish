# Drift reminder - at most once a day, and only when something is actually off.
#
# The check itself runs from cron (config/cron/crontab) into a cache file, so
# this costs one `test -s` at shell startup. Run `dots` any time for a live check.
#
# Disable entirely with:  set -U dotfiles_drift_quiet 1

status is-interactive; or exit 0

function dots -d "dotfiles status and sync"
    switch "$argv[1]"
        case sync
            "$HOME/.config/dotfiles/install/setup.sh" $argv[2..]
        case ''
            "$HOME/.config/dotfiles/install/status.sh"
            # refresh the cache so the reminder reflects reality
            "$HOME/.config/dotfiles/install/status.sh" --quick \
                >"$HOME/.local/state/dotfiles-drift" 2>/dev/null
        case '*'
            "$HOME/.config/dotfiles/install/setup.sh" $argv
    end
end

set -q dotfiles_drift_quiet; and exit 0

set -l _drift "$HOME/.local/state/dotfiles-drift"
set -l _shown "$HOME/.local/state/dotfiles-drift.shown"

test -s "$_drift"; or exit 0

# Only remind once every 24h. You commit periodically; nagging every session
# just trains you to ignore it.
if test -f "$_shown"
    set -l age (math (date +%s) - (stat -f %m "$_shown"))
    test $age -lt 86400; and exit 0
end

set_color yellow
echo "dotfiles out of sync ("(count (cat $_drift))" item(s)) - run: dots"
set_color normal
touch "$_shown"
