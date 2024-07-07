# Dotfiles

## Installation

```bash
cd "$HOME/.config/dotfiles"
git clone https://github.com/MirekNguyen/dotfiles
ln -s "$(readlink -f dotfiles/config/starship.toml)" .
ln -s $(readlink -f dotfiles/config/fish/*.fish) ./fish/conf.d/
```
