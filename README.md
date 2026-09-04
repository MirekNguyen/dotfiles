# Dotfiles

macOS configuration managed with [nix-darwin](https://github.com/LnL7/nix-darwin),
[Homebrew](https://brew.sh) and [GNU Stow](https://www.gnu.org/software/stow/).

Everything is **idempotent** — one command takes a factory-fresh Mac to a fully
configured one, and the same command re-run on a configured Mac converges it to
whatever is currently committed.

## Install

On a brand new Mac (nothing installed, not even `git`):

```bash
curl -fsSL https://raw.githubusercontent.com/MirekNguyen/dotfiles/main/install/install.sh | bash
```

## Re-apply

Once the repo is cloned, this is the only command you need:

```bash
~/.config/dotfiles/install/setup.sh
```

Only touched `mac/flake.nix` and want the fast path:

```bash
nix-rebuild   # alias for: sudo darwin-rebuild switch --flake ~/.config/dotfiles/mac#mira
```

## How it works

`install/install.sh` handles only what must happen before the repo exists
(Command Line Tools, clone) and then hands off to `install/setup.sh`, which runs
five steps in order. Each is independently re-runnable.

| Step | What it does |
| --- | --- |
| `preflight` | Xcode CLT, Rosetta 2, verifies `$USER` matches the flake |
| `nix` | installs Nix (official multi-user installer) if missing |
| `darwin` | moves Apple's `/etc/zshrc` etc. aside, builds and activates the flake |
| `dotfiles` | git submodules, `stow --restow config`, extra symlinks |
| `post` | reports what still needs a human |

The `darwin` step runs before `dotfiles` on purpose: it installs `stow`, `git`
and everything else the later step depends on.

### Running individual steps

```bash
./install/setup.sh --list         # show steps
./install/setup.sh darwin         # just re-activate the flake
./install/setup.sh --skip nix     # everything except Nix installation
./install/setup.sh --yes          # never prompt
```

### Clean install (destructive)

Only on a freshly imaged Mac. Deletes real files in `~/.config` that would block
`stow`, then runs the normal flow:

```bash
~/.config/dotfiles/install/clean-install.sh
```

## Folder structure

```
.
├── install/
│   ├── install.sh          # curl-pipe bootstrap: CLT -> clone -> setup.sh
│   ├── setup.sh            # orchestrator; run this to converge the machine
│   ├── clean-install.sh    # destructive variant for a fresh OS
│   ├── lib/common.sh       # logging, guards, PATH loading, link helper
│   └── steps/
│       ├── 00-preflight.sh
│       ├── 10-nix.sh
│       ├── 20-darwin.sh
│       ├── 30-dotfiles.sh
│       └── 40-post.sh
├── mac/
│   ├── flake.nix           # packages, brews, casks, masApps, macOS defaults
│   ├── flake.lock
│   └── system-settings.md  # settings that cannot be declared in the flake
├── config/                 # stow package -> symlinked into ~/.config
│   ├── fish/ kitty/ ghostty/ aerospace/ sketchybar/ nvim/ (submodule)
│   └── git/ lazygit/ mpv/ yazi/ zsh/ starship.toml ...
├── apps/                   # app settings that aren't dotfiles
│   ├── browser/            # extension configs + firefox-settings.md
│   ├── vscode/             # settings.json, keybindings, extension list
│   └── spicetify/
├── scripts/                # helpers used by fish, sketchybar, kitty
├── windows/                # glazewm + AutoHotkey, for the Windows machine
└── Alfred.alfredpreferences/
```

Adding a step is just dropping a numbered script into `install/steps/`; the
orchestrator picks it up automatically.

## Adding things

| Want to add | Where |
| --- | --- |
| CLI tool from nixpkgs | `mac/flake.nix` → `environment.systemPackages` |
| CLI tool only in Homebrew | `mac/flake.nix` → `homebrew.brews` |
| GUI app | `mac/flake.nix` → `homebrew.casks` |
| Mac App Store app | `mac/flake.nix` → `homebrew.masApps` |
| macOS setting | `mac/flake.nix` → `system.defaults` |
| Dotfile | `config/<tool>/…`, then re-run `setup.sh` |

### Mac App Store apps

`homebrew.masApps` needs the numeric app ID. For an already-installed app:

```bash
mdls -name kMDItemAppStoreAdamID -raw "/Applications/Some App.app"
```

You must be signed into the App Store or the install silently does nothing — the
`post` step checks for this. Note that removing an entry does **not** uninstall
the app (a Homebrew Bundle limitation); delete it by hand.

### Removing things

`homebrew.onActivation.cleanup = "zap"` is on, so any brew or cask **not** listed
in `flake.nix` is uninstalled on the next switch. Comment something out and it
disappears — intentional, but it also means a typo removes apps.

### Using this on a different account

`mac/flake.nix` has a single `username` binding near the top. Change it and the
`preflight` step stops warning. The configuration is named `mira` regardless of
the machine's hostname, so a new Mac needs no renaming.

## Not managed here

A few macOS settings have no nix-darwin option and must be set by hand once per
machine. They are listed in [`mac/system-settings.md`](mac/system-settings.md):
keyboard modifier remaps, custom keyboard shortcuts, input sources and wallpaper.
