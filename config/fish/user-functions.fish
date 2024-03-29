function update
  brew upgrade;
  fisher update &>/dev/null;
  nvim --headless empty +'Lazy update' +'TSUpdateSync' +'MasonUpdate' +qa;
end

function clean
  brew autoremove;
  brew cleanup -s;
  npm cache clean –-force 2>/dev/null;
  # pnpm store prune 1>/dev/null;
  rm -rf "$(brew --cache)";
  rm -rf "$HOME/Applications";
  rm -rf "$HOME/Documents";
  rm -rf "$HOME/Movies";
  rm -rf "$HOME/Music";
  rm -rf "$HOME/.bash_history";
  rm -rf "$HOME/.lesshst";
  rm -rf $(find "/$HOME" -name '\.DS_Store');
  rm -rf "$HOME/.yarnrc"
  rm -rf "$HOME/.mysql_history"
  rm -rf "$HOME/.npm"
  rm -rf "$HOME/.pnpm-state/"
  rm -rf "$HOME/.templateengine/"
  rm -rf "$HOME/.nuget/"
  rm -rf "$HOME/.dotnet/"
  rm -rf "$HOME/.omnisharp/"
  rm -rf "$HOME/.composer/"
  rm -rf "$HOME/.prettierd/"
  rm -rf "$HOME/.wget-hsts"
  rm -rf "$HOME/.python_history"
end

function audio_switch
  if SwitchAudioSource -c | grep -i "speakers"
    blueutil --connect 24-d0-df-99-e7-5a && 
    SwitchAudioSource -s "Mirek’s AirPods Pro" && 
    terminal-notifier -group notifier -message "Airpods" && 
    sleep 1 && 
    terminal-notifier -remove notifier
  else
    SwitchAudioSource -s "MacBook Air Speakers" && 
    terminal-notifier -group notifier -message "Macbook Air Speakers" && 
    sleep 1 &&
    terminal-notifier -remove notifier
  end
end

function mac_info
  terminal-notifier -group notifier -title Info -message "🕰️ $(date "+%T") 🔋 $(pmset -g batt | grep "%" | cut -d')' -f2,2 | cut -d';' -f1,1 | sed -e 's/^[[:space:]]*//')" &&
  sleep 5 &&
  terminal-notifier -remove notifier
end

function z
  if test -f "$argv[1]"
    if file -bL --mime-type "$argv[1]" | grep -iE 'openxmlformats|opendocument' &>/dev/null;
      set -l tmpdir "/tmp/zathura";
      set -l file $(bash -c "filename=$argv[1]; echo \"\${filename%.*}\"")
      soffice --convert-to pdf --outdir "$tmpdir" "$argv[1]" &>/dev/null;
      nohup zathura -- "$tmpdir/$file.pdf" >/dev/null 2>&1 &;
      sleep 1 && rm -rf "$tmpdir";
    else
      nohup zathura -- "$argv[1]" >/dev/null 2>&1 &;
    end
  else
    echo "File doesn't exist";
  end
end

function cheat-fzf
  set -l color $(string join '' \
  "fg:#f8f8f2,bg:#282a36,hl:#bd93f9,"\
  "fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9,"\
  "info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6,"\
  "marker:#ff79c6,spinner:#ffb86c,header:#6272a4")
  set -l fzf "fzf -e --preview="$fzf_find_preview" --cycle --preview-window="$fzf_find_preview" --height 30% --border rounded --color="$color""
  cat $(cheat -l | tail +2 | eval "$fzf" | tr -s ' ' | cut -d ' ' -f2- | rev | cut -d ' ' -f2- | rev) | nvim -R
  commandline --function repaint;
end

function gc
  set -l fzf "fzf -e --preview="$fzf_find_preview" --cycle --preview-window="$fzf_find_preview" --height 30% --border rounded"
  set -l repo "$(gh repo list | sed 's/\t/§/g' | cut -d'§' -f1,1 | eval "$fzf")"
  if test "$repo" = ""
    return
  else
    gh repo clone "$repo";
  end
end
function ltex
  latexmk -halt-on-error -f -pvc -pdf "$argv[1]";
  latexmk -c "$argv[1]";
end

function convert-search
  set input_string (string join " " $argv)
  set output_string ""

  for i in (string split "" $input_string)
    set output_string (string join "" "$output_string" "[[=$i=]]")
  end

  echo $output_string
end

function convert-pdf
  libreoffice --headless --convert-to pdf "$argv[1]"
end
function mp
  nohup mpv "$argv[1]" >/dev/null 2>&1 &;
  disown;
end

function diffstring
  command bash -c "delta <(printf '%s\n' \"$argv[1]\"; echo) <(printf '%s\n' \"$argv[2]\"; echo)"
end

function yabaiinstall
  sudo echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai)) --load-sa" | sudo EDITOR="tee" visudo -f /private/etc/sudoers.d/yabai &&
  yabai --restart-service;
end

function open_images
  set my_files
  for file in *.jpg *.png
    set -a my_files $file
  end
  # qlmanage -p $my_files
  open -a "Preview" $my_files
end
function switch_tabs
  set new_tab_id (kitty @ ls | jq -r '
  .[]
  | select(.is_active)
  | .tabs[]
  | select(.is_focused == false)
  | [.title, "id:\(.id)"]
  | @tsv' | column -ts \t | fzf | awk '{ print $NF }'
  )
  kitty @ focus-tab -m $new_tab_id

end
function extract_links
  set file $argv[1]
  if test -f $file
    set url (grep -o '\[.*\](\(.*\))' $file | sed -e 's/\[\(.*\)\](\(.*\))/\1 \2/g' | fzf | awk '{print $NF}')
    if test -n "$url"
      open -a "Librewolf" $url
    end
  else
    echo "File does not exist"
  end
  commandline --function repaint;
end

function diactritics
  curl -s 'https://korektor.lingea.cz/api/addDiacritics' \
  --compressed \
  -X POST \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  -H 'X-Requested-With: XMLHttpRequest' \
  --data-raw "text=$argv&srcLang=cz" | sed -e 's/<[^>]*>//g'
end

function fish_remove_path
  if set -l index (contains -i "$argv" $fish_user_paths)
    set -e fish_user_paths[$index]
    echo "Removed $argv from the path"
  end
end

function trcz
  set -l str $(echo "$argv" | tr ' ' '+')
  diactritics $str | trans cs:en
end
