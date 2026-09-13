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

## Staying in sync

A cron job runs a cheap check every 15 minutes into
`~/.local/state/dotfiles-drift`. Fish reads that cache and reminds you **at most
once a day**, with a single line:

```
dotfiles out of sync (2 item(s)) - run: dots
```

Silence it for good with `set -U dotfiles_drift_quiet 1`.

| Command | Does |
| --- | --- |
| `dots` | full check now, including decrypting secrets to compare contents |
| `dots` | also resets the daily reminder once you are back in sync |
| `dots sync` | run `setup.sh` - apply everything |
| `./install/setup.sh --status` | same as `dots`, without fish |

It catches: uncommitted or unpushed changes in either repo, secrets edited
locally but not re-encrypted, files in `~/.local/secrets` that nothing is
backing up, a submodule ahead of its pin, a crontab that no longer matches, and
broken stow links.

Drift in `~/.local/secrets` is detected by mtime: the `secrets` step stamps each
decrypted file with its `.enc` mtime, so "plaintext newer than `.enc`" means you
edited it here. That is a `stat` call, which is what keeps the check free.

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
| `secrets` | clones `dotfiles-secrets`, decrypts it into `~/.local/secrets` and `~/.ssh` |
| `dotfiles` | git submodules, `stow --restow config`, symlinks, secrets check |
| `cron` | installs `config/cron/crontab` if it differs from the live one |
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
│   ├── status.sh           # read-only drift report (--quick for the shell)
│   ├── clean-install.sh    # destructive variant for a fresh OS
│   ├── lib/common.sh       # logging, guards, PATH loading, link helper
│   └── steps/
│       ├── 00-preflight.sh
│       ├── 10-nix.sh
│       ├── 20-darwin.sh
│       ├── 25-secrets.sh
│       ├── 30-dotfiles.sh
│       ├── 35-cron.sh
│       └── 40-post.sh
├── mac/
│   ├── flake.nix           # packages, brews, casks, masApps, macOS defaults
│   ├── flake.lock
│   └── system-settings.md  # settings that cannot be declared in the flake
├── config/                 # stow package -> symlinked into ~/.config
│   ├── fish/ kitty/ ghostty/ aerospace/ sketchybar/ nvim/ (submodule)
│   ├── opencode/           # opencode.jsonc; keys via {env:...}
│   ├── agent-browser/  cron/crontab
│   └── git/ lazygit/ mpv/ yazi/ zsh/ starship.toml ...
├── apps/                   # app settings that aren't dotfiles
│   ├── browser/            # extension configs + firefox-settings.md
│   ├── vscode/             # settings.json, keybindings, extension list
│   └── spicetify/
├── scripts/                # helpers used by fish, sketchybar, kitty
│   └── secret              # add/edit/sync the encrypted secret store
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
| Cron job | `config/cron/crontab`, then `./install/setup.sh cron` |
| Secret | `~/.local/secrets/environment` (never the repo) |

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

## Secrets

Secrets live in a **separate private repo**, [`MirekNguyen/dotfiles-secrets`](https://github.com/MirekNguyen/dotfiles-secrets),
encrypted with [sops](https://github.com/getsops/sops) + [age](https://github.com/FiloSottile/age).
Nothing is ever stored in plaintext outside this machine.

```
dotfiles (public)                    dotfiles-secrets (private, encrypted)
├── config/ssh/personal.conf         ├── .sops.yaml
└── install/steps/25-secrets.sh      ├── personal/{environment,ssh,wireguard,kube,hosts}
                                     └── work/{ssh,vpn,o2-cz.p12,work-servers.json}
```

### Recovery on a lost/new machine

The **only** thing you must carry by hand is the age private key:

1. Restore it from your password manager (item `age key - dotfiles-secrets`) to
   `~/.config/sops/age/keys.txt`, mode `0600`.
2. `curl -fsSL .../install/install.sh | bash`

The `secrets` step then clones the private repo and decrypts `~/.local/secrets/`,
`~/.ssh/id_ed25519`, the O2 keys and `~/.ssh/config.d/work.conf`.

Public recipient of the current key:

```
age1edp75lnfr4ssspm3epp9wy86gv0had347tazdcxn0s3tfqua2qqshd00kn
```

### Working with secrets

`scripts/secret` is the only interface you need. Paths are always relative to
`$HOME`.

```sh
secret ls                                     # what is in the store
secret add .local/secrets/foo.conf            # start tracking a new file
secret add .local/secrets/o2.conf work        # ...in the work tier
secret edit .local/secrets/environment        # add/change an env var
secret cat  .local/secrets/environment        # print decrypted
secret push                                   # commit + push (refuses plaintext)
secret sync                                   # decrypt everything back into $HOME
```

**Adding an environment variable** is `secret edit .local/secrets/environment`,
add the line, save, then `secret push && secret sync`.

Layout is convention-driven, so there is no list to maintain anywhere:

    <tier>/home/<path>.enc      ->  $HOME/<path>          (mode 0600)
    <tier>/home/<dir>.tar.enc   ->  extracted into $HOME  (hides member names)

`environment` is encrypted in dotenv mode so `git diff` shows *which* key
changed; everything else is opaque binary.

### Adding a second machine

Generate an age key there, add its public key under `keys:` in `.sops.yaml`, then
`sops updatekeys <file>` for each file and push.

### ssh_config

`~/.ssh/config` only contains `Include` lines. Host blocks are split so the public
repo never sees internal hostnames:

| Fragment | Source | Contents |
| --- | --- | --- |
| `config.d/personal.conf` | `config/ssh/personal.conf` (public) | `github.com`, `hetzner`, `work` |
| `config.d/work.conf` | `~/.local/secrets/ssh/work.conf` (encrypted) | `*.ux.to2cz.cz`, `git-it.cz.o2`, work username |

## Not managed here

A few macOS settings have no nix-darwin option and must be set by hand once per
machine. They are listed in [`mac/system-settings.md`](mac/system-settings.md):
keyboard modifier remaps, custom keyboard shortcuts, input sources and wallpaper.
