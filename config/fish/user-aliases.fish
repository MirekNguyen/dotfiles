alias v='nvim'
alias w='webtorrent download --out "$HOME"/Downloads'
alias n "newsboat -q"
alias n3 "nnn -A -d -H -P f"
alias f "ranger"
alias icat="kitty +kitten icat"
alias libreoffice="soffice"

# ssh
alias r "ssh binh@mirekng.com"

# cd
alias icloud="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/"
alias d='cd ~/Desktop'
alias do='cd ~/Downloads/'
alias ido='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Downloads'
alias notes='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Notes'

# exa
alias ls='exa -g --oneline'
alias la='exa -g -a --oneline'
alias ll='exa -g -l'
alias lla='exa -g -la'

#mount
alias mount-notes="rclone mount --vfs-cache-mode writes 'ncloud:Media/Notes' $HOME/.local/mount/nextcloud-notes/"
alias unmount-notes="umount -f $HOME/.local/mount/nextcloud-notes/"
alias cd-notes="cd ~/.local/mount/nextcloud-notes"

alias mount-next="rclone mount --vfs-cache-mode writes 'ncloud:' $HOME/.local/mount/nextcloud/"
alias unmount-next="umount -f $HOME/.local/mount/nextcloud/"
alias cd-next="cd ~/.local/mount/nextcloud"
alias unmount-all="umount -f $HOME/.local/mount/*"

# chatgpt
alias chatgpt="chatgpt-cli --settings="$HOME/.local/share/chatgpt-cli/settings.js""
alias bing="chatgpt-cli --settings="$HOME/.local/share/chatgpt-cli/settings-bing.js""
