
# pnpm
set -gx PNPM_HOME "/Users/mireknguyen/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
