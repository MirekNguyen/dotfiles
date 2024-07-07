alias v='nvim'
alias b "btm --basic"
alias f="yazi"
alias btm "btm --color gruvbox --mem_as_value --group"
alias bat "bat --theme=gruvbox-dark --style=numbers --color=always"
alias mans="apropos . | grep \(1\) | sed 's/(1)//g' | fzf | cut -d' ' -f1,1 | xargs -I {} man {}"
alias fzf "fzf -e --height 30% --border rounded"

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

# copilot, git
alias ghs "gh copilot suggest"

# ssh
alias r "ssh -C -A binh@mirekng.com"
alias dietpi "ssh -C -A -p 10 binh@mirekng.com"

# mount
alias raspberry-pi-mount "mount_smbfs //binh:62MNB5q5efbs8@binh/share $HOME/.local/mount/raspberry-pi"
alias dietpi-mount "mount_smbfs //binh:62MNB5q5efbs8@10.0.0.150/dietpi $HOME/.local/mount/dietpi"
alias u "umount ~/.local/mount/*"

# wifi
alias airport "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport"
alias internet-speed "curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -"

# work
alias docker-ps "docker ps -a --format 'table {{.ID}}|{{.Names}}|{{.Status}}|{{.Ports}}' | column -t -s '|'"
alias backup-spokojenost "zip -r $HOME/.local/projects/backup/o2-spokojenost-$(date +"%Y-%m-%dT%H:%M:%S").zip "$HOME"/.local/projects/o2-spokojenost"
alias backup-omnichannel "zip -r $HOME/.local/projects/backup/$(date +"%Y-%m-%dT%H:%M:%S")_omnichannel.zip $HOME/.local/projects/omnichannel -x $HOME/.local/projects/omnichannel/.docker/mysql/dumps/\*"

function diffstring
  diff <( printf '%s\n' "$1" ) <( printf '%s\n' "$2" )
end

alias ai "gh copilot suggest"
alias omniphp "docker-compose -f /Users/mireknguyen/.local/projects/work/omnichannel/docker-compose-custom.yml exec php php"
