# XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker 
export HOMEBREW_CASK_OPTS="--appdir=/Applications/_Casks"
export LESSHISTFILE=-

set fish_greeting
set -gx EDITOR nvim 
set -gx TERM xterm-256color

# nnn
set -gx NNN_FIFO '/tmp/nnn.fifo'
set -gx NNN_PLUG 'f:preview-tui;'

# chatgpt-cli
set -gx STORAGE_FILE_PATH "$HOME/.local/share/chatgpt-cli/cache.json"
