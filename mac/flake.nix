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
        [ pkgs.argocd
          pkgs.bat
          pkgs.bottom
          pkgs.cargo
          pkgs.php83Packages.composer
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
          pkgs.wget
          pkgs.yazi
          pkgs.zinit
          pkgs.zoxide
        ];
      system.defaults = {
        dock = {
          autohide = true;
          orientation = "left";
          expose-group-by-app = true;
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
          "hashicorp/tap"
        ];
        brews = [
            "ansible"
            "ansible-lint"
            "cliclick"
            "colima"
            "dotnet"
            "felixkratz/formulae/sketchybar"
            "fish"
            "fisher"
            "hashicorp/tap/terraform"
            "openjdk"
            "php"
            "vpn-slice"
        ];
        casks = [
          "nikitabobko/tap/aerospace"
          "alfred"
          "appcleaner"
          "chromium"
          "keyboardcleantool"
          "kitty"
          "macfuse"
          "microsoft-teams"
          "moonlight"
          "mos"
          "onedrive"
          "phpstorm"
          "sf-symbols"
          "stolendata-mpv"
          "shortcat"
          "shottr"
          "spotify"
          "swift-quit"
          "wezterm"
          "zen-browser"
        ];
        onActivation.cleanup = "zap";
      };
      fonts.packages = with pkgs; [
          iosevka
          (nerdfonts.override { fonts = [ "Iosevka" ]; })
      ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
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
