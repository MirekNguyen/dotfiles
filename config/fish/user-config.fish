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
