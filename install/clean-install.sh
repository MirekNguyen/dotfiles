#!/usr/bin/env bash

git clone git@github.com:MirekNguyen/dotfiles.git "$HOME"/.config/dotfiles

cd "$HOME"/.config/dotfiles || exit
stow -D -t "$HOME"/.config config
stow -t "$HOME"/.config config

ln -s '/Users/mireknguyen/Library/Mobile Documents/com~apple~CloudDocs/' "$HOME"/.local/cloud
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/.config/dotfiles/mac#mira
