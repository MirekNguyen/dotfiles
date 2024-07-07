function update
  brew upgrade;
  fisher update &>/dev/null;
  nvim --headless empty +'Lazy update' +'TSUpdateSync' +'MasonUpdate' +qa;

  echo -n "Updating dotfiles..."
  git -C "$HOME/.config/dotfiles" pull
  echo -n "Updating nvim..."
  git -C "$HOME/.config/nvim" pull
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

function gc
  set -l fzf "fzf -e --preview="$fzf_find_preview" --cycle --preview-window="$fzf_find_preview" --height 30% --border rounded"
  set -l repo "$(gh repo list | sed 's/\t/§/g' | cut -d'§' -f1,1 | eval "$fzf")"
  if test "$repo" = ""
    return
  else
    gh repo clone "$repo";
  end
end

function mpv
  nohup mpv "$argv[1]" >/dev/null 2>&1 &;
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

function flush-dns
  sudo dscacheutil -flushcache
  sudo killall -HUP mDNSResponder
  networksetup -setairportpower en0 off
  networksetup -setairportpower en0 on
end

function route-flush
  networksetup -setairportpower en0 off
  sudo route flush
  sudo ifconfig en1 down
  sudo ifconfig en1 up
  networksetup -setairportpower en0 on
end

function sanitize
  echo "$argv" | string replace -a '/' '\/' | pbcopy
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

function git-switch --description="Switch branches using fzf"
  git switch "$(git branch | fzf | tr -d "[:space:]")"
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

function work-vpn-connect
    echo "$WORK_VPN_PASSWORD" | sudo openconnect -c "$HOME"/.config/o2-cz.p12 -s 'vpn-slice 10.0.0.0/8 172.26.193.0/24' zamevpn.o2.cz --passwd-on-stdin --background
end

function work
  function work-on
      work-vpn-connect;
      osascript -e 'tell application "Librewolf" to close (every window)'
      osascript -e 'tell application "Librewolf" to activate'
      open -a "Librewolf" "https://jira.cz.o2/secure/RapidBoard.jspa?rapidView=922&projectKey=SSD" &&
      open -a "Librewolf" "https://jira.cz.o2/secure/Tempo.jspa#/my-work/timesheet"
      open -g -a "Mail";
      open -g -a "Microsoft Teams (work or school)";
      open -g -a "kitty";
      pkill -f kitty;
      cd "$HOME/.local/projects/work";
      kitty @ set-tab-title project
      kitten @ launch --type=tab --title finder
      kitten @ launch --type=tab --title todo
      kitty @ focus-tab -m title:project
      colima start;
      sleep 2 && osascript -e 'tell application "kitty" to activate'
      osascript -e 'tell application "Finder" to set volume 0'
  end
  function work-off
      sudo pkill -9 openconnect; flush-dns; route-flush
      osascript -e 'tell application "Librewolf" to close (every window)'
      pkill -9 "Microsoft Outlook";
      pkill -9 "Mail";
      pkill -9 "Flow";
      osascript -e 'tell application "Microsoft Teams (work or school)" to quit' &>/dev/null;
      pkill -9 "PhpStorm";
      pkill -9 "Postman";
      pkill -f kitty;
      cd;
      open -a "Librewolf"
      osascript -e 'tell application "kitty" to activate'
      osascript -e 'tell application "Librewolf" to activate'
  end

  function omnichannel
      vpn
      osascript -e 'tell application "Librewolf" to close (every window)'
      osascript -e 'tell application "Librewolf" to activate'
      open -a "Librewolf" "https://git-it.cz.o2/omni-be/omnichannel" &&
      open -a "Librewolf" "https://jira.cz.o2/secure/RapidBoard.jspa?rapidView=624&projectKey=OMNI" &&
      open -a "Librewolf" "https://jira.cz.o2/secure/Tempo.jspa#/my-work/timesheet"
      open -g -a "Mail";
      open -g -a "Microsoft Teams (work or school)";
      open -g -a "kitty";
      open -g -a "Flow";
      pkill -f kitty;
      cd "$HOME/.local/projects/work/omnichannel/";
      kitty @ set-tab-title project
      kitten @ launch --type=tab --title finder
      kitten @ launch --type=tab --title database
      kitten @ launch --type=tab --title ncspot
      kitten @ launch --type=tab --title todo
      kitten @ launch --type=tab --title omni-fe
      cd "$HOME/.local/projects/work/omni-calc-ui/app/";
      yarn start;
      kitty @ focus-tab -m title:project
      colima start;
      docker-compose -f "$HOME/.local/projects/work/omnichannel/docker-compose-custom.yml" up -d;
      docker-compose -f "$HOME/.local/projects/work/o2-spokojenost/docker-compose.yml" up -d;
      sleep 2 && osascript -e 'tell application "kitty" to activate'
      osascript -e 'tell application "Finder" to set volume 0'
  end

  set -l option "$(gum choose "on" "off" "afterwork" "study" "omnichannel")"
  switch "$option"
    case "on"
      work-on
    case "off"
      work-off
    case "afterwork"
      vpn
    case  "study"
      work-off
      open -a "Librewolf" "https://discord.com/"
    case "omnichannel"
      work-on
  end
end

function diffstring
  diff <( printf '%s\n' "$1" ) <( printf '%s\n' "$2" )
end
