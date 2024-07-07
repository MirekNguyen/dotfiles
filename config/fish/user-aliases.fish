# shortcuts
alias v='nvim'
alias b "btm --basic"
alias f="yazi"
alias btm "btm --theme gruvbox --process_memory_as_value --group_processes"
alias bat "bat --theme=gruvbox-dark --style=numbers --color=always"
alias mans="apropos . | grep \(1\) | sed 's/(1)//g' | fzf | cut -d' ' -f1,1 | xargs -I {} man {}"
alias fzf "fzf -e --height 30% --border rounded"
alias ai "gh copilot suggest"
alias airport "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport"
alias docker-ps "docker ps -a --format 'table {{.ID}}|{{.Names}}|{{.Status}}|{{.Ports}}' | column -t -s '|'"

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

# apps
alias apps="osascript -e 'tell application \"System Events\" to get the name of (every application process whose background only is false)'"
alias mpv "mpv --player-operation-mode=pseudo-gui --script-opts=ytdl_hook-ytdl_path=yt-dlp --ytdl-format='bestvideo[height<=?1080]+bestaudio/best'"
alias libreoffice="soffice"

# nvim
alias chat "nvim -c 'set filetype=chatgpt' -c 'ChatGPT'"
alias db "nvim -c 'set filetype=db' -c 'DBUIToggle'"
