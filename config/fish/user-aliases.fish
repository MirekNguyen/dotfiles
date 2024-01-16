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
alias images="timg --grid=4 --title --center $(fd --max-depth 1 --regex '^*.\.(jpg|png|gif|jpeg|avif|webp|tiff|bmp)' .)"
alias apps="osascript -e 'tell application \"System Events\" to get the name of (every application process whose background only is false)'"
alias mpv "mpv --player-operation-mode=pseudo-gui --script-opts=ytdl_hook-ytdl_path=yt-dlp --ytdl-format='bestvideo[height<=?1080]+bestaudio/best'"
alias ghs "gh copilot suggest"
alias ghss "gh copilot suggest -t shell"
alias ghsgit "gh copilot suggest -t git"

# ssh
alias r "ssh -C -A binh@mirekng.com"

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
alias l='eza -g -la'

alias f="yazi"
