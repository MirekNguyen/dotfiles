#!/usr/bin/env zsh

fzf-find-search() {
    local fzf_base_dir="${PWD}"
    local swap_path=false

    if [[ $# -eq 1 ]]; then
        if [[ ! -e "$1" ]]; then
            echo "Provided path doesn't exist"
            return 1
        fi
        fzf_base_dir="$1"
    elif [[ $# -eq 2 ]]; then
        if [[ ! -e "$1" ]] || [[ ! -e "$2" ]]; then
            echo "Provided path doesn't exist"
            return 1
        fi
        fzf_base_dir="$1"
        swap_path=true
    fi

    local number=$(($(echo "$fzf_base_dir" | awk -F'/' '{print NF}') + 1))
    local fzf=$(rg -x '^.*.{4,}' -n --ignore-file "$fzf_find_search_ignore" -H "$fzf_base_dir" \
        | fzf -e --delimiter / --with-nth $number.. --preview="$fzf_find_search_preview" \
          --cycle --preview-window="$fzf_find_search_preview_window" --height 30% --border rounded)

    if [[ -z "$fzf" ]]; then
        return 0
    fi

    local file_path=$(echo "$fzf" | cut -d':' -f1)
    local line=$(echo "$fzf" | cut -d':' -f2)

    if type nvim >/dev/null 2>&1; then
        if [[ $swap_path == true ]]; then
            file_path="${file_path/$1/$2}"
        fi
        cd "$(dirname "$file_path")"
        nvim +"$line" "$file_path" -c 'normal zt'
    else
        $EDITOR "$file_path"
    fi

    return 0
}
