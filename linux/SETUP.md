# Arch setup

One-time steps for a fresh install. Packages are in `packages.txt`; install
them with `linux/packages.sh install`.

## Before installing packages

Enable multilib for Steam: uncomment in `/etc/pacman.conf`

```
[multilib]
Include = /etc/pacman.d/mirrorlist
```

then `sudo pacman -Syu`. When installing Steam, pick `lib32-nvidia-utils`.

## Services

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

## Key remapping

xremap reads `/dev/input` directly:

```sh
sudo usermod -aG input binh
```

## System files

- Sudoers: `sudo nvim /etc/sudoers.d/00_binh`
- Bootloader: `sudoedit /boot/loader/loader.conf` and set `timeout 0`

## TODO

- Auto launch Hyprland
- Auto login
