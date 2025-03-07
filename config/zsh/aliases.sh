# shortcuts
alias v='nvim'
alias btm="btm --theme gruvbox --process_memory_as_value --group_processes"
alias bat="bat --theme=gruvbox-dark --style=numbers --color=always"
alias fzf="fzf -e --height 30% --border rounded"
alias docker-ps="docker ps -a --format 'table {{.ID}}|{{.Names}}|{{.Status}}|{{.Ports}}' | column -t -s '|'"
alias c='click.sh "$HOME"/.local/secrets/websites'
alias k='kubectl'

# eza
alias ls='eza -g --oneline'
alias la='eza -g -a --oneline'
alias ll='eza -g -l'
alias lla='eza -g -la'
alias l='eza -g -la'

# ssh, mount
alias sshlx='ssh-servers.sh "$HOME"/.local/secrets/work-servers.json'
alias sshs='ssh-servers.sh "$HOME"/.local/secrets/home-servers.json'
alias mnt='smb-servers.sh "$HOME"/.local/secrets/smb-servers.json'
alias db='nvim -c "set filetype=sql" -c "DBUIToggle"'
alias nix-rebuild='darwin-rebuild switch --flake "$HOME"/.config/dotfiles/mac#mira'
alias nix-update='nix flake update "$HOME"/.config/dotfiles/mac'
