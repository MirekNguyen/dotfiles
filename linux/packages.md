# Installed packages

- networkmanager hyprland kitty openssh git

- nvidia-open nvidia-utils nvidia-settings


# Extra packages

``
sudo pacman -Syu \
    opencode
    github-cli
    rofi
    fish
    fisher
    fd
    fzf
    eza
    git-delta
    lazygit
    stow
    unzip
    zip
    bottom
    yazi
    waybar
    otf-font-awesome
    ttf-iosevka-nerd
    darkman
    gnome-calendar
    swaync
    hyprpaper
    wl-clipboard
    cliphist
    hyprshot
    hyprlock
    hypridle
    neovim
    tree-sitter-cli
    xdg-desktop-portal-hyprland # screen sharing
    hyprpolkitagent
    nautilus
    wireguard-tools
    vpn-slice
    systemd-resolvconf
    gum
    starship

# Auto dark mode
systemctl --user enable --now darkman

# Bluetooth
sudo pacman -S bluez bluez-utils
sudo systemctl enable --now bluetooth
``

# YAY packages

```
sudo yay -S \
    xremap-hypr-bin
    overskride
    spotify
    discord
    teams-for-linux
    proton-pass-bin
    jellium-desktop-git
    localsend
    telegram-desktop
    lutris
    sunshine-bin
```

# Remap keys

```
sudo usermod -aG input binh
```


# Installed drivers

# Install Steam
Open /etc/pacman.conf with a text editor `sudo vi /etc/pacman.conf`

```
[multilib]
Include = /etc/pacman.d/mirrorlist
```
Installation
`sudo pacman -Syu steam` and choose option `lib32-nvidia-utils` (nvidia GPU)




# Auto launch hyprland

# Auto login

# Sound
sudo pacman -S wireplumber alsa-utils pipewire-pulse

systemctl --user enable pipewire pipewire-pulse wireplumber


# Sudoers
sudo nvim /etc/sudoers.d/00_binh

# Bootloader
`sudoedit /boot/loader/loader.conf`
- set value `timeout 0`


# Sunshine
Optional: enable avahi so Moonlight finds this PC on the network by itself. It's installed but turned off. Without it, add the PC in Moonlight by its IP address.
sudo systemctl enable --now avahi-daemon
