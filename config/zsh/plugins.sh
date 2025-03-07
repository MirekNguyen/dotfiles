ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light joshskidmore/zsh-fzf-history-search
# autoload -U compinit && compinit

eval "$(starship init zsh)"
eval "$(zoxide init --cmd cd zsh)"

# plugins
source "$HOME/.config/dotfiles/scripts/fzf-find.sh"
source "$HOME/.config/dotfiles/scripts/fzf-find-search.sh"
source "$HOME/.config/dotfiles/scripts/load-env.sh"
source "$HOME/.config/dotfiles/scripts/work.sh"
load-env "$HOME"/.local/secrets/environment
