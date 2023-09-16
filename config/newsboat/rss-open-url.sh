#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")";
row=$(grep "$4" "./urls");
if ! echo "$row" | grep '\^'; then 
  if [[ "$(uname -s)" == "Darwin" ]]; then
    if echo "$1" | grep -i "youtube"; then
      nohup mpv --player-operation-mode=pseudo-gui --script-opts=ytdl_hook-ytdl_path=yt-dlp --ytdl-format="best" "$1" >/dev/null 2>&1 &
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
