alias v='nvim'
alias w='webtorrent download --out "$HOME"/Downloads'
alias n "newsboat -q && neomutt -z"
alias b "btm -b"
alias btm "btm --color gruvbox"
alias icat="kitty +kitten icat"
alias libreoffice="soffice"
alias mans="apropos . | grep \(1\) | sed 's/(1)//g' | fzf | cut -d' ' -f1,1 | xargs -I {} man {}"
alias mvi="mpv --config-dir=$HOME/.config/mvi &>/dev/null"
alias img="open -a \"Preview\""
alias apps="osascript -e 'tell application \"System Events\" to get the name of (every application process whose background only is false)'"

# ssh
alias r "ssh binh@mirekng.com"

# cd
alias icloud="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/"
alias do='cd ~/downloads/'
alias ido='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Downloads'
alias notes='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Notes'

# eza
alias ls='eza -g --oneline'
alias la='eza -g -a --oneline'
alias ll='eza -g -l'
alias lla='eza -g -la'

alias f="yazi"
