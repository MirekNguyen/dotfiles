{
  description = "Mira Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
    let
      configuration = { pkgs, ... }: {
        environment.systemPackages =
          [
            pkgs.bat
            pkgs.bottom
            pkgs.delta
            pkgs.docker
            pkgs.docker-compose
            pkgs.dotenv-linter
            pkgs.duf
            pkgs.dust
            pkgs.eza
            pkgs.fd
            pkgs.fx
            pkgs.fzf
            pkgs.gh
            pkgs.gum
            pkgs.imagemagick
            pkgs.jq
            pkgs.kubectl
            pkgs.lazygit
            pkgs.lua
            pkgs.go
            pkgs.nodejs
            # pkgs.openconnect
            pkgs.pnpm
            pkgs.ripgrep
            # pkgs.spicetify-cli
            pkgs.starship
            pkgs.stow
            pkgs.wget
            pkgs.yazi
            pkgs.terraform
          ];
        system.defaults = {
          dock = {
            autohide = true;
            orientation = "left";
            expose-group-apps = true;
            persistent-apps = [];
          };
          NSGlobalDomain = {
            NSAutomaticWindowAnimationsEnabled = false;
            NSWindowShouldDragOnGesture = true;
          };
        };
        system.primaryUser = "mireknguyen";

        homebrew = {
          enable = true;
          taps = [
            "nikitabobko/tap"
            "felixkratz/formulae"
            "shivammathur/extensions"
            "shivammathur/php"
            "hashicorp/tap"
          ];
          brews = [
            "agent-browser"
            # "aicommits"
            "composer"
            "fish"
            "fisher"
            "fx"
            "mpv"
            "neovim"
            "shivammathur/php/php@7.4"
            # "shivammathur/php/php@5.6"
            # "shivammathur/extensions/mcrypt@5.6"
            # "switchaudio-osx"
            "felixkratz/formulae/sketchybar"
            "vpn-slice"
            "wireguard-tools"
            "xcode-build-server"
            "openconnect"
            "zellij"
            "ruby"
            "xcbeautify"
            "coreutils"
            "oven-sh/bun/bun"
            "aicommit2"
            "tree-sitter-cli"
            "opencode"
            "jira-cli"
            "mas"
            "helm"
            "bun"
            "gromgit/fuse/sshfs-mac"
          ];
          casks = [
            "nikitabobko/tap/aerospace"
            "alfred"
            # "altserver"
            "appcleaner"
            "kitty"
            "microsoft-teams"
            "phpstorm"
            "sf-symbols"
            "spotify"
            "orbstack"
            # "krita"
            # "jellyfin-media-player"
            # "logi-options+"
            "omnidisksweeper"
            "telegram"
            # "wacom-tablet"
            "microsoft-outlook"
            # "betterdisplay"
            # "visual-studio-code"
            "microsoft-word"
            "microsoft-excel"
            "microsoft-powerpoint"
            # "transmit"
            "moonlight"
            # "figma"
            # "whatsapp"
            "steam"
            # "google-chrome"
            # "unity"
            # "unity-hub"
            # "blender"
            # "yaak"
            "discord"
            # "dyad"
            # "nordvpn"
            # "notion"
            # "windows-app"
            # "mos"
            # "keyboardcleantool"
            # "shottr"
            # "swift-quit"
            "vorssaint"
            # "zen"
            "helium-browser"
            "rustdesk"
          ];
          masApps = {
            "Menu Bar Controller for Sonos" = 6749351423;
          };
          # Extra untracked apps
          # - CrossOver
          # - Final Cut Pro
          # - Jellium Desktop
          onActivation.cleanup = "zap";
        };
        fonts.packages = with pkgs; [
          iosevka
          nerd-fonts.iosevka
        ];

        # nix.package = pkgs.nix;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";
        nix.settings.use-xdg-base-directories = true;

        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true;  # default shell on catalina
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 5;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin"; # x86_64-darwin

        nixpkgs.config.allowUnfree = true;
      };
    in
      {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."mira" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              # Apple Silicon Only
              enableRosetta = true;
              # User owning the Homebrew prefix
              user = "mireknguyen";
              # Automatically migrate existing Homebrew installations
              autoMigrate = true;
              # Homebrew 6.0+ requires third-party taps to be trusted before
              # `brew bundle` will load their formulae/casks. Declare trust here
              # so activation (which runs as root) doesn't fail on untrusted taps.
              # Note: removing entries here does NOT revoke trust; use `brew untrust`.
              trust = {
                taps = [
                  "nikitabobko/tap"
                  "felixkratz/formulae"
                  "shivammathur/extensions"
                  "shivammathur/php"
                  "hashicorp/tap"
                  "oven-sh/bun"
                ];
                formulae = [
                  "shivammathur/php/php@7.4"
                  "shivammathur/php/php@5.6"
                  "shivammathur/extensions/mcrypt@5.6"
                  "felixkratz/formulae/sketchybar"
                  "oven-sh/bun/bun"
                ];
                casks = [
                  "nikitabobko/tap/aerospace"
                ];
                commands = [ ];
              };
            };
          }
        ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."mira".pkgs;
    };
}
