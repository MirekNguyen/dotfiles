#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")" || exit;
row=$(grep "$4" "./urls");
if ! echo "$row" | grep '\^'; then 
  if [[ "$(uname -s)" == "Darwin" ]]; then
    if echo "$1" | grep -i "youtube"; then
      # nohup mpv --player-operation-mode=pseudo-gui --script-opts=ytdl_hook-ytdl_path=yt-dlp --ytdl-format='22/18/17/bv+ba' --no-sub "$1" >/dev/null 2>&1 &
      XDG_RUNTIME_DIR="/tmp/users/$(id -u)";
      rm -rf "$XDG_RUNTIME_DIR/ytaudio" >/dev/null;
      yt-dlp -N 8 --no-part -f "wa[acodec~=opus]/ba" "$1" -o "${XDG_RUNTIME_DIR}/ytaudio";
      nohup yt-dlp -f "bestvideo[height<=?1080]" "$1" -o - | mpv --audio-file="${XDG_RUNTIME_DIR}/ytaudio" - > /dev/null 2>&1 & disown;
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
  # chapter=${echo "$chapter" | sed 's/^-//g'};
  chapter=$(echo "$2" | grep -oE '\d+([.,]\d+)?' | tail -1);
  echo "$chapter" > ~/Downloads/chapter.txt;
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
  episode=$(echo "$2" | grep -E -ow '[0-9]{2}');
  mount_dir="$(fish -c 'echo "$SERVER_MOUNT"')"
  ssh_mount="$(fish -c 'echo "$SERVER_SSH_MOUNT"')"
  if ! mount | grep "on $mount_dir" > /dev/null; then
    mount_smbfs //binh/share "$mount_dir" || sshfs "$ssh_mount" "$mount_dir";
  fi

  file="$(fd . --full-path "${mount_dir}" | fzf -e --select-1 --exit-0 --query "$title $episode")";
  if ! [ -f "$file" ]; then
    terminal-notifier -group notifier -title Error -message "Could not parse RSS feed" &&
    terminal-notifier -remove notifier
  else
    fish -C "mp \"$file\"";
  fi
fi
