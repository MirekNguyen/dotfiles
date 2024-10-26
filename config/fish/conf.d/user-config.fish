set -U fish_user_paths "$HOME"/.local/go/bin "$HOME"/.local/cargo/bin "$HOME"/.local/bin "$HOME"/.config/dotfiles/scripts /opt/local/bin /opt/homebrew/bin /opt/homebrew/opt/fzf/bin $fish_user_paths

# Loading licence keys from .env
function envsource
  if [ -f $argv ]
    for line in (cat $argv | grep -v '^#')
      set item (string split -m 1 '=' $line)
      set -gx $item[1] $item[2]
    end
  end
end
envsource "$HOME/.config/dotfiles/config/fish/.env"
envsource "$HOME/.local/secrets/environment"

# Starship
if type -q starship
  starship init fish | source
end


# XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker 
export HOMEBREW_CASK_OPTS="--appdir=/Applications/_Casks"
export LESSHISTFILE=-

set fish_greeting
set -gx EDITOR nvim 
set -gx MANPAGER "sh -c 'col -bx | bat --theme=gruvbox-dark -l man -p'"
set -gx TERM xterm-256color

# XDG
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_STATE_HOME "$HOME/.local/log"

# Configuration
set -gx LS_COLORS "di=36"
set -gx BAT_THEME "gruvbox-dark"

# PATH
set -gx GOPATH "$HOME/.local/scripts/go"
set -gx CARGO_HOME "$HOME/.local/scripts/cargo/"
set -gx LIMA_HOME "$HOME/.config/lima"
set -gx RLWRAP_HOME "$XDG_DATA_HOME/translate-shell/"
set -gx PM2_HOME "$XDG_DATA_HOME/pm2"

set -gx NPM_CONFIG_USERCONFIG "$XDG_CONFIG_HOME/npm/npmrc"
set -gx OPENAI_MODEL "gpt-4o-2024-08-06"
set -gx VAULT_ADDR 'http://127.0.0.1:8200'
# set -gx DOCKER_HOST "unix://$HOME/.config/colima/docker.sock"
