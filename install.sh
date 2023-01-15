#!/bin/bash
cd "$(dirname "${BASH_SOURCE[0]}")";
path=$(pwd);
# ln -s ./.gitconfig "$HOME/.config/git/config";
# ln -s ./config.fish "$HOME/.config/fish/config.fish";
# ln -s ./kitty/ "$HOME/.config/kitty";
# ln -s ./newsboat/ "$HOME/.config/newsboat";
linkArray=(\
  "./.gitconfig|$HOME/.config/git/config" \
  "./config.fish|$HOME/.config/fish/config.fish" \
  "./kitty/|$HOME/.config/kitty" \
  "./newsboat/|$HOME/.config/newsboat");

for str in ${linkArray[@]}; do
  source=$(echo "$str" | cut -d'|' -f1,1);
  target=$(echo "$str" | cut -d'|' -f2,2);
  if [ -L ${target} ] && [ -e ${target} ]; then
    echo "Link: ${target} already exists";
  else
    ln -s "$path/$source" "$target";
  fi
done

if [ command -v fisher &>/dev/null ]; then
  fisher install mireknguyen/fzf_find;
  fisher install IlanCosman/tide@v5;
else
  echo "Command: fisher not found";
fi
if [ ! -f "$HOME/.config/nvim" ]; then
  echo "Folder: $HOME/.config/nvim already exists";
else
  git clone git@github.com:MirekNguyen/nvim.git "$HOME/.config/nvim";
fi
