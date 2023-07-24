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
# set -gx TERM xterm-kitty

# nnn
set -gx NNN_FIFO '/tmp/nnn.fifo'
set -gx NNN_PLUG 'f:-preview-tui;q:-quicklook'
set -gx NNN_OPENER "$HOME/.config/nnn/plugins/nuke"
set -gx NNN_FCOLORS 'c1e2042e006033f7c6d6abc4'
