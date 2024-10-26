function update
  brew upgrade;
  fisher update &>/dev/null;
  nvim --headless empty +'Lazy update' +'TSUpdateSync' +'MasonUpdate' +qa;
end

function clean
  brew autoremove;
  brew cleanup -s;
  npm cache clean –-force 2>/dev/null;
  rm -rf "$(brew --cache)";
  rm -rf "$HOME/Applications";
  rm -rf "$HOME/Documents";
  rm -rf "$HOME/Movies";
  rm -rf "$HOME/Music";
  rm -rf "$HOME/.bash_history";
  rm -rf "$HOME/.lesshst";
  rm -rf "$(find "/$HOME" -name '\.DS_Store')";
  rm -rf "$HOME/.yarnrc"
  rm -rf "$HOME/.mysql_history"
  rm -rf "$HOME/.npm"
  rm -rf "$HOME/.pnpm-state/"
  rm -rf "$HOME/.profile"
  rm -rf "$HOME/.cisco/"
  rm -rf "$HOME/.pm2"
  rm -rf "$HOME/.vpn"
  rm -rf "$HOME/.rnd"
  rm -rf "$HOME/.templateengine/"
  rm -rf "$HOME/.nuget/"
  rm -rf "$HOME/.dotnet/"
  rm -rf "$HOME/.omnisharp/"
  rm -rf "$HOME/.composer/"
  rm -rf "$HOME/.prettierd/"
  rm -rf "$HOME/.wget-hsts"
  rm -rf "$HOME/.python_history"
  rm -rf "$HOME/.symfony5"
end

function zath
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

function mpv
  nohup mpv --player-operation-mode=pseudo-gui --script-opts=ytdl_hook-ytdl_path=yt-dlp --ytdl-format='bestvideo[height<=?1080]+bestaudio/best' "$argv[1]" >/dev/null 2>&1 &;
  disown;
end

function yabaiinstall
  sudo echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai)) --load-sa" | sudo EDITOR="tee" visudo -f /private/etc/sudoers.d/yabai &&
  yabai --restart-service;
end


function fish_remove_path
  if set -l index (contains -i "$argv" $fish_user_paths)
    set -e fish_user_paths[$index]
    echo "Removed $argv from the path"
  end
end

function dark-mode
  set choice "$(gum choose "dark" "light")"
  if test "$choice" = "light"
    kitty +kitten themes --reload-in=all 'Gruvbox Material Light Soft' &&
    osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to false' &&
    perl -i -p -e 's/gruvbox-dark/gruvbox-light/g' "$HOME"/.config/git/config
    set -Ux DARK_MODE false
  else
    kitty +kitten themes --reload-in=all 'Gruvbox Material Dark Medium' &&
    osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true' &&
    perl -i -p -e 's/gruvbox-light/gruvbox-dark/g' "$HOME"/.config/git/config
    set -Ux DARK_MODE true
  end
  echo '⌃+⌘+, to reload'
end

function work-vpn-connect
  echo "$WORK_VPN_PASSWORD" | sudo openconnect -c "$HOME"/.local/secrets/o2-cz.p12 -s 'vpn-slice 10.0.0.0/8 172.26.193.0/24' zamevpn.o2.cz --passwd-on-stdin --background
end

function work-vpn-disconnect
  sudo pkill -9 openconnect
  # flush dns
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
  networksetup -setairportpower en0 off
  networksetup -setairportpower en0 on

  # route flush
  networksetup -setairportpower en0 off
  sudo route flush
  sudo ifconfig en1 down
  sudo ifconfig en1 up
  networksetup -setairportpower en0 on
end

function work-vpn
  set -l option "$(gum choose "connect" "disconnect")"
  switch "$option"
    case "connect"
      work-vpn-connect;
    case "disconnect"
      sudo pkill -9 openconnect; flush-dns; route-flush
  end
end


function work
  function work-on
      work-vpn-connect;
      osascript -e 'tell application "Librewolf" to close (every window)'
      osascript -e 'tell application "Librewolf" to activate'
      open -a "Librewolf" "https://jira.cz.o2/secure/RapidBoard.jspa?rapidView=922&projectKey=SSD" &&
      open -a "Librewolf" "https://jira.cz.o2/secure/Tempo.jspa#/my-work/timesheet"
      open -g -a "Mail";
      open -g -a "Microsoft Teams";
      open -g -a "kitty";
      pkill -f kitty;
      cd "$HOME/.local/projects/work";
      kitty @ set-tab-title project
      sleep 2 && osascript -e 'tell application "kitty" to activate'
      osascript -e 'tell application "Finder" to set volume 0'
  end
  function work-off
      work-vpn-disconnect;
      osascript -e 'tell application "Librewolf" to close (every window)'
      pkill -9 "Microsoft Outlook";
      pkill -9 "Mail";
      pkill -9 "Flow";
      osascript -e 'tell application "Microsoft Teams" to quit' &>/dev/null;
      pkill -9 "PhpStorm";
      pkill -f kitty;
      cd;
      open -a "Librewolf"
      osascript -e 'tell application "kitty" to activate'
      osascript -e 'tell application "Librewolf" to activate'
  end

  set -l option "$(gum choose "on" "off")"
  switch "$option"
    case "on"
      work-on
    case "off"
      work-off
  end
end

function rest
  set basePath "/Users/mireknguyen/.local/projects/personal/rest-nvim"
  set choice "$(gum choose "$basePath"/*.http)"
  nvim "$choice"
end
