# Rules

## Don't make permanent system changes without asking

Edit files in the repo freely. The line is permanence: anything that changes
the PC's settings beyond the current session is for the user to do. Say what
should be run and why, and let them decide.

### Fine without asking

- Read-only commands for information: `ls`, `cat`, `grep`, `--version`,
  `pacman -Q`, `systemctl status`, `journalctl`, `hyprctl monitors`, etc.
- Restarting or reloading things so edits take effect: `systemctl --user
  restart`, `pkill` + relaunch of a daemon (waybar, hyprpaper, swaync, ...),
  `hyprctl reload`, signals like `SIGUSR2`, `swaync-client --reload-css`.
- Temporary, session-only changes that are gone after a relogin, like `hyprctl`
  runtime setters.
- Scratch files in `/tmp/opencode`.

### Ask first

- Installing, removing or updating packages (pacman, yay/paru, nix, brew,
  `npm -g`, pip, `cargo install`, ...).
- Persistent service state: `systemctl enable/disable/mask/unmask`, creating or
  editing unit files, `daemon-reload` for new units, `loginctl enable-linger`.
- Persistent settings: `gsettings set`/dconf, `darkman set/toggle`, `localectl`,
  `timedatectl`, `hostnamectl`, and similar.
- Creating or changing symlinks, crontabs, or files outside the repo (for example
  under `~/.config`, `~/.local`, `/etc`).
- Anything needing `sudo`, and anything touching hardware, network, users or
  groups.

If unsure whether something persists, ask.

## Keep it simple

- Prefer a small, plain function over configurable or clever code. Don't add
  guards, fallbacks or abstractions for cases that don't happen.
- Few code comments: only where the code can't explain itself.
- Keep replies short. Say what changed and what the user has to do, nothing more.
