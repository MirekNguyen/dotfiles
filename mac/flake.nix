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
          pkgs.ansible
          pkgs.ansible-lint
          pkgs.argocd
          pkgs.bat
          pkgs.bottom
          pkgs.cargo
          pkgs.delta
          pkgs.docker
          pkgs.docker-compose
          pkgs.duf
          pkgs.dust
          pkgs.eza
          pkgs.fd
          pkgs.fx
          pkgs.fzf
          pkgs.gh
          pkgs.gum
          pkgs.kubectx
          pkgs.kubernetes-helm
          pkgs.jq
          pkgs.kubectl
          pkgs.lazygit
          pkgs.lazysql
          pkgs.lua
          pkgs.mariadb
          pkgs.neovim
          pkgs.nodejs
          pkgs.openconnect
          pkgs.openjdk
          pkgs.pnpm
          pkgs.postgresql
          pkgs.ripgrep
          pkgs.spicetify-cli
          pkgs.starship
          pkgs.stow
          pkgs.terraform
          pkgs.wget
          pkgs.yazi
          pkgs.zinit
          pkgs.zoxide
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

      homebrew = {
        enable = true;
        taps = [
          "nikitabobko/tap"
          "felixkratz/formulae"
          "shivammathur/php"
        ];
        brews = [
            "aichat"
            "cliclick"
            "fish"
            "fisher"
            "mpv"
            "php@8.3"
            "shivammathur/php/php@7.4"
            "felixkratz/formulae/sketchybar"
            "vpn-slice"
        ];
        casks = [
          "nikitabobko/tap/aerospace"
          "alfred"
          "appcleaner"
          "chromium"
          "iina"
          "keyboardcleantool"
          "kitty"
          "macfuse"
          "microsoft-teams"
          "moonlight"
          "mos"
          "phpstorm"
          "sf-symbols"
          "shortcat"
          "shottr"
          "spotify"
          "swift-quit"
          "omnidisksweeper"
          "orbstack"
          "visual-studio-code"
          "zen-browser"
        ];
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
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."mira".pkgs;
  };
}
