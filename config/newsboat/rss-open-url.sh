#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")";
row=$(grep "$4" "./urls");
if ! echo "$row" | grep '\^'; then 
  if [[ "$(uname -s)" == "Darwin" ]]; then
    if echo "$1" | grep -i "youtube"; then
      nohup mpv --no-sub "$1" >/dev/null 2>&1 &
      disown;
    else
      open "$1";
    fi
  else
    xdg-open "$1";
  fi
  exit 0;
fi

command=$(echo "$row" | cut -d'^' -f2,2 | cut -d'"' -f1,1);
if echo "$command" | grep '{chapter}'; then
  chapter=$(echo "$2" | tr -dc '0-9.' | tr '.' '-');
  newcommand="${command/\{chapter\}/$chapter}";
  eval "$newcommand";
  exit 0;
fi

if echo "$command" | grep '{url}'; then
  newcommand="${command/\{url\}/$1}";
  eval "$newcommand";
  exit 0;
fi

if echo "$command" | grep '{title}'; then
  title="${command/\{title\}/$4}";
  # echo "$newcommand" > /Users/mireknguyen/Downloads/rss.log;
  episode=$(echo "$2" | grep -E -ow '[0-9]{2}');
  file="$(fd . "/Users/mireknguyen/.local/mount/fedora/" | fzf --select-1 --query "$title $episode")"
  if ! [ -f "$file" ] ; then
    terminal-notifier -group notifier -title Error -message "Could not parse RSS feed" &&
    terminal-notifier -remove notifier
  else
    open "$file"
  fi
  # kitty @ launch --type=tab --title "$title" && \
  # kitty @ send-text --match "title:\"$title\"" \
  # "clear && \
  # mp \$(
  #   fd . "/Users/mireknguyen/.local/mount/fedora/" | fzf --query \"$title $episode\"
  # ) && kitten @ close-tab --match 'title:\"$title\"' \\r"
  # fd --literal \"$title\" "/Users/mireknguyen/.local/mount/fedora/" | fzf
  # nohup mpv "/Users/mireknguyen/.local/mount/fedora/anime/Frieren - Beyond Journey's End/$newcommand" >/dev/null 2>&1 &
  # exit 0;
fi

#  "^kitty @ launch --type=tab --title Webtorrent && kitty @ send-text --match 'title:Webtorrent' webtorrent download {url} -o $HOME/Downloads/ \\r"
