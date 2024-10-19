function ltex
  latexmk -halt-on-error -f -pvc -pdf "$argv[1]";
  latexmk -c "$argv[1]";
end

function diffstring
  command bash -c "delta <(printf '%s\n' \"$argv[1]\"; echo) <(printf '%s\n' \"$argv[2]\"; echo)"
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

function trcz
  set -l str $(echo "$argv" | tr ' ' '+')
  diactritics $str | trans cs:en
end

function omni-jira
  set -l sprint '1824'
  set -l option "$(gum choose "backlog" "list" "assigned" "assigned-all")"
  switch "$option"
    case "backlog"
      jira issue list -q "project = OMNI AND status in (\"To Do\", New) AND component = BE AND Sprint = $sprint AND assignee in (EMPTY)"
    case "list"
      jira issue list -q "project = OMNI AND issuetype in standardIssueTypes() AND component in (BE, FE) AND Sprint = $sprint"
    case "assigned"
      jira issue list -a\$(jira me) -q 'project = OMNI' -s~Canceled -s~Done
    case "assigned-all"
      jira issue list -a\$(jira me)
  end
end

function pom
  while true
    echo "$(pomodoro status)" | grep "❗️⏱ " && terminal-notifier -title TLDR -message 'end';
    sleep 5;
  end
end

function wifi --description 'Wifi management'
  set -l option "$(gum choose "connect" "on" "off" "status")"
  switch "$option"
    case "connect"
      set -l airport "$(airport -s | fzf --header-lines=1 --layout=reverse | perl -pe 's/  +/\t/g' | sed 's/\t//' | sed 's/\t.*//')"
      networksetup -setairportnetwork en0 "$airport"
    case "on"
      networksetup -setairportpower en0 on
    case "off"
      networksetup -setairportpower en0 off
    case "status"
      airport -I
  end
end

function git-switch --description="Switch branches using fzf"
  git switch "$(git branch | fzf | tr -d "[:space:]")"
end

function gc
  set -l fzf "fzf -e --preview="$fzf_find_preview" --cycle --preview-window="$fzf_find_preview" --height 30% --border rounded"
  set -l repo "$(gh repo list --limit 1000 | sed 's/\t/§/g' | cut -d'§' -f1,1 | eval "$fzf")"
  if test "$repo" = ""
    return
  else
    gh repo clone "$repo";
  end
end

