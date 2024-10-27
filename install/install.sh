#!/usr/bin/env bash

git clone git@github.com:MirekNguyen/dotfiles.git "$HOME"/.config/dotfiles

cd "$HOME"/.config/dotfiles || exit
stow -D -t "$HOME"/.config config
stow -t "$HOME"/.config config
fisher update


# nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.config/dotfiles/mac#mira

# # XDG
# if [[ -z "$XDG_CONFIG_HOME" ]]
# then
#         export XDG_CONFIG_HOME="$HOME/.config/"
# fi
#
# if [[ -d "$XDG_CONFIG_HOME/zsh" ]]
# then
#         export ZDOTDIR="$XDG_CONFIG_HOME/zsh/"
# fi

nvim -c 'set filetype=install'
