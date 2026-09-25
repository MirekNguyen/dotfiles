# Arch setup

One-time steps after archinstall, in the order they were done on this machine.
Packages are in `packages.txt`; install them with `linux/packages.sh install`.

archinstall already set up: user `binh` in `wheel` with sudo, `en_US.UTF-8`,
`us` keymap, systemd-boot, zram swap, and the services `systemd-networkd`,
`systemd-resolved`, `systemd-timesyncd`, `fstrim.timer`.

## 1. Before installing packages

Enable multilib for Steam: uncomment in `/etc/pacman.conf`

```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

and while there, uncomment `Color`. Then `sudo pacman -Syu`.

Build yay by hand, since it's the tool that installs everything else:

```sh
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
```

Then `linux/packages.sh install`. When Steam asks, pick `lib32-nvidia-utils`.

## 2. System

```sh
sudo timedatectl set-timezone Europe/Prague
```

NVIDIA: kernel modesetting, needed by Hyprland.

```sh
echo 'options nvidia_drm modeset=1 fbdev=1' | sudo tee /etc/modprobe.d/nvidia.conf
sudo mkinitcpio -P
```

Monitor brightness keys (ddcutil). Also turn on DDC/CI in the monitor's menu.

```sh
echo i2c-dev | sudo tee /etc/modules-load.d/i2c-dev.conf
sudo usermod -aG i2c binh
```

Bootloader: skip the systemd-boot menu. `/boot/loader/loader.conf`:

```
timeout 0
#console-mode keep
```

Sudo without a password prompt:

```sh
echo 'binh ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/00_binh
sudo chmod 440 /etc/sudoers.d/00_binh
```

## 3. Login straight into Hyprland

Auto login on tty1: `sudo systemctl edit getty@tty1` and add

```ini
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin binh --noclear %I $TERM
```

Hyprland then starts from the login shell on tty1. fish does it through
`config/fish/conf.d/hyprland-autostart.fish` (in the repo). The same block is
in `~/.bash_profile` as a fallback while the shell is still bash:

```sh
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
    exec start-hyprland
fi
```

## 4. User and shell

```sh
chsh -s /usr/bin/fish
sudo usermod -aG input binh         # xremap reads /dev/input directly
```

SSH key for GitHub, then add the public key at github.com/settings/keys:

```sh
ssh-keygen -C "mireknguyenbinh@gmail.com"
gh auth login
```

## 5. Dotfiles

```sh
git clone --recurse-submodules git@github.com:MirekNguyen/dotfiles.git ~/.config/dotfiles
stow --restow --dir ~/.config/dotfiles --target ~/.config config
```

The Linux-only configs are linked by hand:

```sh
D=~/.config/dotfiles/linux
ln -sfn $D/hypr   ~/.config/hypr
ln -sfn $D/waybar ~/.config/waybar
ln -sfn $D/swaync ~/.config/swaync
ln -sfn $D/nwg-dock-hyprland ~/.config/nwg-dock-hyprland
mkdir -p ~/.local/share/darkman ~/.local/share/applications
ln -sfn $D/darkman/theme-switch.sh ~/.local/share/darkman/theme-switch.sh
ln -sfn $D/applications/steam.desktop   ~/.local/share/applications/
ln -sfn $D/applications/spotify.desktop ~/.local/share/applications/
```

fish plugins (the list is `config/fish/fish_plugins`): `fisher update`.

## 6. Services

```sh
systemctl --user enable pipewire pipewire-pulse wireplumber
systemctl --user enable --now darkman           # auto light/dark theme
sudo systemctl enable --now bluetooth
```

Optional, for Sunshine: lets Moonlight find this PC on the network by itself.
Without it, add the PC in Moonlight by its IP address.

```sh
sudo systemctl enable --now avahi-daemon
```

## 7. Outside pacman

- aicommit2, used by lazygit for commit messages. npm installs into
  `~/.local/share/npm` (see `config/npm`):

  ```sh
  npm install -g aicommit2
  ```

- SpotX, the Spotify ad blocker. It patches the files in `/opt/spotify`, so
  it has to be re-run after every Spotify update:

  ```sh
  bash <(curl -sSL https://spotx-official.github.io/run.sh)
  ```

- AppImages in `~/Applications` (downloaded by hand): Eden and citron
  (Switch emulators), NX Optimizer, Gemini Desktop.
