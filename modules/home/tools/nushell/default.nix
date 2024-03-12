{ lib, config, pkgs, inputs, ... }:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  cfg = config.nazarick.tools.nushell;
in
{
  options.nazarick.tools.nushell = {
    enable = mkEnableOption "Nushell";
  };

  config = mkIf cfg.enable {
    home.file.".config/starship.toml".source = ./starship/starship.toml;

    home.file.".config/nushell" = {
      source = ./config;
      recursive = true;
    };

    services.gpg-agent = {
      enable = true;
      enableNushellIntegration = true;
      enableSshSupport = true;
      pinentryFlavor = "curses";
    };

    services.pueue.enable = true;
    programs = {
      nushell = {
        enable = true;
        # The overlay is applied here
        package = pkgs.nushell;
        configFile.text = builtins.readFile ./config.nu;
        envFile.text = builtins.readFile ./env.nu;
      };

      starship = {
        enable = true;
        enableNushellIntegration = true;
      };

      atuin = {
        enable = true;
        package = pkgs.atuin;
        enableNushellIntegration = true;
        settings = {
          inline_height = 15;
          style = "compact";
        };
      };

      zoxide = {
        enable = true;
        enableNushellIntegration = true;
      };

      eza = {
        enable = true;
      };

      bat = {
        enable = true;
        config = {
          theme = "catppuccin_mocha";
        };
        themes = {
          catppuccin_mocha = {
            src = pkgs.fetchurl {
              url = "https://raw.githubusercontent.com/catppuccin/bat/2bafe4454d8db28491e9087ff3a1382c336e7d27/themes/Catppuccin%20Mocha.tmTheme";
              sha256 = "sha256-F4jRaI6KKFvj9GQTjwQFpROJXEVWs47HsTbDVy8px0Q=";
            };
          };
        };
      };

      tealdeer = {
        enable = true;
        settings = {
          display = {
            compact = true;
          };
          updates = {
            auto_update = true;
            auto_update_interval_hours = 1440;
          };
        };
      };
    };
  };
}
