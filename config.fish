export HOMEBREW_CASK_OPTS="--appdir=/Applications/_Casks"
set fish_greeting
set -gx EDITOR nvim 
set -gx TERM xterm-256color

alias icloud="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/"
alias prog="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Programming/"
alias web="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Programming/Websites"
alias d='cd ~/Desktop'
alias rasp="ssh pi@mirekng.com"
alias web='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Programming/Websites/'
alias scripts='cd ~/.local/bin'
alias fish-reload='source ~/.config/fish/config.fish'
alias ls='exa --icons -g --oneline'
alias la='exa --icons -g -a --oneline'
alias ll='exa --icons -g -l'
alias lla='exa --icons -g -la'
alias v='nvim'
alias do='cd ~/Downloads/'
alias ido='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Downloads'
alias notes='cd ~/Library/Mobile\ Documents/com~apple~CloudDocs/Notes'
alias youtube='cd ~/Downloads/Youtube'
alias soffice='/Applications/_Casks/LibreOffice.app/Contents/MacOS/soffice'
alias w='webtorrent download --out "$HOME"/Downloads'
alias bat='bat --style=plain --theme gruvbox-dark --color=always'
alias update='brew upgrade && brew autoremove && brew cleanup && fisher update &>/dev/null & nvim --headless -c "autocmd User PackerComplete quitall" -c "PackerSync"'
alias cleanup='brew autoremove && brew cleanup && npm cache clean --force && pnpm store prune'

# pnpm
set -gx PNPM_HOME "/Users/mireknguyen/Library/pnpm"
set -gx PATH "$PNPM_HOME" $PATH
# pnpm end
