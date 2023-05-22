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
