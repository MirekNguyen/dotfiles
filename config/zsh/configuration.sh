export PATH="$HOME"/.config/dotfiles/scripts:/opt/homebrew/bin:$PATH

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/log"

export EDITOR="nvim"
export MANPAGER="sh -c 'col -bx | bat --theme=gruvbox-dark -l man -p'"
export TERM="xterm-256color"
export LS_COLORS="di=36"
export BAT_THEME="gruvbox-dark"
export LESSHISTFILE=-
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker 
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export OPENAI_MODEL="gpt-4o-2024-08-06"

export ANSIBLE_HOME="${XDG_CONFIG_HOME}/ansible"
export ANSIBLE_CONFIG="${XDG_CONFIG_HOME}/ansible.cfg"
export ANSIBLE_GALAXY_CACHE_DIR="${XDG_CACHE_HOME}/ansible/galaxy_cache"

export fzf_find_ignore="$HOME/.config/dotfiles/config/fdignore"
export fzf_find_search_ignore="$HOME/.config/dotfiles/config/fdignore"
export fzf_find_search_preview_window="right,40%"
export fzf_find_search_preview='bat --theme=gruvbox-dark --style=plain --color=always --line-range=$(echo {} | cut -d":" -f2): --highlight-line=$(echo {} | cut -d":" -f2) $(echo {} | cut -d":" -f1)'
export FZF_DEFAULT_OPTS="${FZF_NON_COLOR_OPTS[*]} \
--color=bg+:#3c3836,bg:#282828,spinner:#8ec07c,hl:#83a598 \
--color=fg:#bdae93,header:#83a598,info:#fabd2f,pointer:#8ec07c \
--color=marker:#8ec07c,fg+:#ebdbb2,prompt:#fabd2f,hl+:#83a598"

setopt auto_cd
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*:git-checkout:*' sort false
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' switch-group '<' '>'

HISTSIZE=5000
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

bindkey -s '6;9u' "^Qfzf-find $HOME^M"
bindkey -s '6;10u' "^Qfzf-find --noignorefile^M"
bindkey -s '8;9u' "^Qfzf-find-search $HOME/.local/notes/programming/^M"
bindkey -s '8;10u' "^Qfzf-find-search^M"

autoload -z edit-command-line
zle -N edit-command-line
bindkey "^[e" edit-command-line
