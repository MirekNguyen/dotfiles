set -gx fzf_find_ignore "$HOME/.config/dotfiles/config/fdignore"
set -gx fzf_find_search_ignore "$HOME/.config/dotfiles/config/fdignore"
set -gx fzf_find_search_preview_window "right,40%"
set -gx fzf_find_search_preview \
"bat --theme=gruvbox-dark \
--style=plain --color=always \
--line-range=(echo {} | cut -d':' -f2): \
--highlight-line=(echo {} | cut -d':' -f2) \
(echo {} | cut -d':' -f1)"
