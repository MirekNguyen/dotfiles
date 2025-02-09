set fish_greeting
set -U fish_user_paths "$HOME/.config/dotfiles/scripts/" /Users/mireknguyen/.dotnet/tools /Users/mireknguyen/.nix-profile/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin /opt/local/bin /opt/homebrew/bin /opt/homebrew/opt/fzf/bin $fish_user_paths

# aliases
alias v='nvim'
alias fzf "fzf -e --height 30% --border rounded"
alias docker-ps "docker ps -a --format 'table {{.ID}}|{{.Names}}|{{.Status}}|{{.Ports}}' | column -t -s '|'"
alias c 'click.sh "$HOME"/.local/secrets/websites'
alias k 'kubectl'
alias g 'git'
alias lg 'lazygit'
alias d 'docker'
alias kn 'kubens'
alias kx 'kubectx'
alias ls='eza -g --oneline'
alias l='eza -g -la'
alias db 'nvim -c "set filetype=sql" -c "DBUIToggle"'

# ssh, mount
alias sshlx 'ssh-servers.sh "$HOME"/.local/secrets/work-servers.json'
alias sshs 'ssh-servers.sh "$HOME"/.local/secrets/home-servers.json'
alias mnt 'smb-servers.sh "$HOME"/.local/secrets/smb-servers.json'
alias nix-rebuild 'darwin-rebuild switch --flake ~/.config/dotfiles/mac#mira'

# XDG
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx XDG_DATA_HOME "$HOME/.local/share"
set -gx XDG_CACHE_HOME "$HOME/.cache"
set -gx XDG_STATE_HOME "$HOME/.local/log"

# Configuration
set -gx EDITOR nvim 
set -gx TERM xterm-256color
set -gx LS_COLORS "di=36"
set -gx GOPATH "$HOME/.local/scripts/go"
set -gx CARGO_HOME "$HOME/.local/scripts/cargo/"
set -gx NPM_CONFIG_USERCONFIG "$XDG_CONFIG_HOME/npm/npmrc"

set -gx LIMA_HOME "$HOME/.config/lima"
set -gx DOCKER_CONFIG "$XDG_CONFIG_HOME"/docker
set -gx KUBECONFIG "$XDG_CONFIG_HOME/kube" 
set -gx KUBECACHEDIR "$XDG_CACHE_HOME/kube"

set -gx VAULT_ADDR "https://vault.mirekng.com"

bind \e\[106\;9u "_fzf_find $HOME"
bind \e\[108\;9u "_fzf_find_search '$HOME/.local/mount/onedrive/notes/programming/'"
bind \e\[106\;10u "_fzf_find --noignorefile"
bind \e\[108\;10u "_fzf_find_search"

# Starship
if type -q starship
  starship init fish | source
end

# Loading licence keys from .env
function envsource
  if [ -f $argv ]
    for line in (cat $argv | grep -v '^#')
      set item (string split -m 1 '=' $line)
      set -gx $item[1] $item[2]
    end
  end
end
envsource "$HOME/.local/secrets/environment"
