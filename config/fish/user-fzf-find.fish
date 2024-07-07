set -gx fzf_find_scope "$HOME"
set -gx fzf_find_preview ""
set -gx fzf_find_ignore "$HOME/.config/dotfiles/config/fdignore"

# set -gx fzf_find_search_scope "/Users/mireknguyen/Library/Mobile Documents/com~apple~CloudDocs/notes"
set -gx fzf_find_search_scope "$HOME/.local/notes"
set -gx fzf_find_search_ignore "$HOME/.config/dotfiles/config/fdignore"
set -gx fzf_find_search_preview_window "right,40%"
set -gx fzf_find_search_preview \
"bat --theme=gruvbox-dark \
--style=plain --color=always \
--line-range=(echo {} | cut -d':' -f2): \
--highlight-line=(echo {} | cut -d':' -f2) \
(echo {} | cut -d':' -f1)"

set -l color00 '#282828'
set -l color01 '#3c3836'
set -l color02 '#504945'
set -l color03 '#665c54'
set -l color04 '#bdae93'
set -l color05 '#d5c4a1'
set -l color06 '#ebdbb2'
set -l color07 '#fbf1c7'
set -l color08 '#fb4934'
set -l color09 '#fe8019'
set -l color0A '#fabd2f'
set -l color0B '#b8bb26'
set -l color0C '#8ec07c'
set -l color0D '#83a598'
set -l color0E '#d3869b'
set -l color0F '#d65d0e'

set -l FZF_NON_COLOR_OPTS

for arg in (echo $FZF_DEFAULT_OPTS | tr " " "\n")
    if not string match -q -- "--color*" $arg
        set -a FZF_NON_COLOR_OPTS $arg
    end
end

set -gx FZF_DEFAULT_OPTS "$FZF_NON_COLOR_OPTS"\
" --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D"\
" --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C"\
" --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D"

