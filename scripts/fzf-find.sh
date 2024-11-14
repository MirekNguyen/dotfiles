#!/usr/bin/env zsh

fzf-find() {
    local fzf_base_dir="$(pwd)"
    local swap_path=false
    local noignorefile=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --noignorefile)
                noignorefile=true
                shift
                ;;
            *)
                break
                ;;
        esac
    done

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

    local fzf_cmd
    if [[ "$noignorefile" == true ]]; then
        fzf_cmd="fd -I -L --base-directory=\"$fzf_base_dir\" --strip-cwd-prefix -H -t f -t d"
    else
        fzf_cmd="fd -I -L --base-directory=\"$fzf_base_dir\" --ignore-file=\"$fzf_find_ignore\" --strip-cwd-prefix -H -t f -t d"
    fi

    local fzf
    fzf=$(eval "$fzf_cmd" | fzf -e --preview="$fzf_find_preview" --cycle --preview-window="$fzf_find_preview" --height 30% --border rounded)

    if [[ -z "$fzf" ]]; then
        return 0
    fi

    if [[ "$swap_path" == false ]]; then
        fzf="$fzf_base_dir/$fzf"
    else
        fzf="$2/$fzf"
    fi

    if [[ -f "$fzf" ]]; then
        cd "$(dirname "$fzf")"
        extension="${fzf##*.}"
        case "$extension" in
            mkv|mp4)
                nohup mpv --player-operation-mode=pseudo-gui "$fzf" >/dev/null 2>&1 &
                disown
                ;;
            pdf)
                nohup zathura -- "$fzf" >/dev/null 2>&1 &
                disown
                ;;
            odt|ods|odp|sxw|doc|docx|xls|xlsx|ppt|pptx)
                open "$fzf"
                ;;
            *)
                "$EDITOR" "$fzf"
                ;;
        esac
        return 0
    fi

    if [[ -d "$fzf" ]]; then
        cd "$fzf"
        return 0
    fi

    echo "Path is not a file or a directory"
    return 1
}
