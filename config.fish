export HOMEBREW_CASK_OPTS="--appdir=/Applications/_Casks"

export LESSHISTFILE=-

set fish_greeting
set -gx EDITOR nvim 
set -gx TERM xterm-256color

alias icloud="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/"
alias d='cd ~/Desktop'
alias scripts='cd ~/.local/bin'
alias fish-reload='source ~/.config/fish/config.fish'
alias ls='exa -g --oneline'
alias la='exa -g -a --oneline'
alias ll='exa -g -l'
alias lla='exa -g -la'
alias v='nvim'
alias do='cd ~/Downloads/'
alias ido='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Downloads'
alias notes='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Notes'
alias w='webtorrent download --out "$HOME"/Downloads'
