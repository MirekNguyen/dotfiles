set fish_greeting
set -U fish_user_paths "/opt/homebrew/opt/ruby/bin" "$HOME/.local/share/npm" "$HOME/.local/scripts/cargo/bin" "$HOME/.local/scripts/go/bin" "$HOME/.local/share/npm/bin/" "$HOME/.config/dotfiles/scripts/" /Users/mireknguyen/.dotnet/tools /Users/mireknguyen/.nix-profile/bin /run/current-system/sw/bin /nix/var/nix/profiles/default/bin /opt/local/bin /opt/homebrew/bin /opt/homebrew/opt/fzf/bin "" $fish_user_paths

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
alias wake-pc "ssh binh@vpn.mirekng.com \"wakeonlan bc:fc:e7:53:ba:b6\""
alias psql 'psql-17'
alias pc 'wake-pc; /Applications/BetterDisplay.app/Contents/MacOS/BetterDisplay set -UUID=8C15F480-4D22-4376-8053-24EC3E9B5C03 -ddc -vcp=inputSelect -value=17'

# ssh, mount
alias sshlx 'ssh-servers.sh "$HOME"/.local/secrets/work-servers.json'
alias sshs 'ssh-servers.sh "$HOME"/.local/secrets/home-servers.json'
alias mnt 'smb-servers.sh "$HOME"/.local/secrets/smb-servers.json'
alias nix-rebuild 'sudo darwin-rebuild switch --flake ~/.config/dotfiles/mac#mira'
alias nix-update 'nix flake update --flake ~/.config/dotfiles/mac'

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
bind \e\[106:74\;10u "_fzf_find --noignorefile"
bind \e\[108:76\;10u "_fzf_find_search"
bind \e\[105\;9u "dev.sh"
bind \e\[117\;9u "bw-login.sh"
bind \e\[107\;9u "yazi"

# Starship
if type -q starship
  starship init fish | source
end

# Loading licence keys from .env
function envsource
  if not test -f "$argv[1]"
    return 0
  end
  for line in (cat "$argv[1]")
    # Skip blank lines and comments.
    if string match -qr '^\s*($|#)' -- $line
      continue
    end
    set -l item (string split -m 1 '=' -- $line)
    # Skip anything that is not KEY=value.
    if test (count $item) -ne 2
      continue
    end
    set -l key (string trim -- $item[1])
    # `set` errors out on anything that is not a valid variable name.
    if not string match -qr '^[A-Za-z_][A-Za-z0-9_]*$' -- $key
      continue
    end
    set -gx $key (string trim -- $item[2])
  end
end
envsource "$HOME/.local/secrets/environment"

# sops looks here for the age identity that decrypts ~/.config/dotfiles-secrets
set -gx SOPS_AGE_KEY_FILE "$HOME/.config/sops/age/keys.txt"
alias secrets 'cd ~/.config/dotfiles-secrets'


function yy
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file=$tmp
    set cwd (cat -- $tmp)
    if test -s $tmp
        if test -n "$cwd" -a "$cwd" != "$PWD"
            cd -- $cwd
            commandline -f repaint
        end
    end
    rm -f -- $tmp
end
