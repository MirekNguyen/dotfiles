function update
  brew upgrade;
  fisher update &>/dev/null;
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
    nohup zathura -- "$argv[1]" >/dev/null 2>&1 &;
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
  cat $(cheat -l | tail +2 | eval "$fzf" | tr -s ' ' | cut -d' ' -f2,2) | nvim -R
  commandline --function repaint;
end

function gc
  set -l color $(string join '' \
    "fg:#f8f8f2,bg:#282a36,hl:#bd93f9,"\
    "fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9,"\
    "info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6,"\
    "marker:#ff79c6,spinner:#ffb86c,header:#6272a4")
  set -l fzf "fzf -e --preview="$fzf_find_preview" --cycle --preview-window="$fzf_find_preview" --height 30% --border rounded --color="$color""
  set -l repo "$(gh repo list | sed 's/\t/§/g' | cut -d'§' -f1,1 | eval "$fzf")"
  if test "$repo" = ""
    return
  else
    gh repo clone "$repo";
  end
end
