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
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.bat
          pkgs.bottom
          pkgs.php83Packages.composer
          pkgs.docker
          pkgs.docker-compose
          pkgs.dotnet-sdk
          pkgs.duf
          pkgs.dust
          pkgs.eza
          pkgs.fd
          pkgs.sketchybar
          pkgs.fx
          pkgs.fzf
          pkgs.gh
          pkgs.git-extras # git-delta
          pkgs.gum
          pkgs.kubernetes-helm
          pkgs.jq
          pkgs.kubectl
          pkgs.lua
          pkgs.mariadb
          pkgs.nodejs-slim
          pkgs.openconnect
          pkgs.pnpm
          pkgs.postgresql
          pkgs.ripgrep
          pkgs.spicetify-cli
          pkgs.starship
          pkgs.stow
          pkgs.vpn-slice
          pkgs.wget
          pkgs.zathura
        ];
      system.defaults = {
        dock = {
          autohide = true;
          orientation = "left";
        };
      };

      homebrew = {
        enable = true;
        taps = [
          "jorgerojas26/lazysql"
          "felixkratz/formulae"
          "koekeishiya/formulae"
        ];
        brews = [
          "cliclick"
          "felixkratz/formulae/sketchybar"
          "fisher"
          "jorgerojas26/lazysql"
          "koekeishiya/formulae/skhd"
          "koekeishiya/formulae/yabai"
          "neovim"
          "php"
          "yazi"
        ];
        casks = [
          "alfred"
          "appcleaner"
          "betterdisplay"
          "chromium"
          "kitty"
          "librewolf"
          "macfuse"
          "microsoft-teams"
          "moonlight"
          "mos"
          "mpv"
          "onedrive"
          "orbstack"
          "sf-symbols"
          "shortcat"
          "shottr"
          "spotify"
          "swift-quit"
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

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      programs.fish.enable = true;

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
