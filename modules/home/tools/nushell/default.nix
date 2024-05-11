{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt;

  cfg = config.nazarick.tools.nushell;
in
{
  options.nazarick.tools.nushell = {
    enable = mkEnableOption "Nushell";
  };

  options.nazarick.home = {
    environmentVariables = mkOpt (types.attrsOf types.str) { } "Environment variables";
  };

  config = mkIf cfg.enable {

    systemd.user.services = {
      nushell-history = {
        Unit = {
          Description = "Make atuin history nushell history";
        };

        Service = {
          Type = "oneshot";
          ExecStart = ''${pkgs.nushell}/bin/nu -c "ATUIN_SESSION='blank' ${pkgs.atuin}/bin/atuin history list --cmd-only | split row '\n' | reverse | uniq | reverse | save -f ${config.home.homeDirectory}/.config/nushell/history.txt"'';
        };

        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };

    xdg.configFile."starship.toml" = {
      enable = true;
      source = ./starship/starship.toml;
    };

    xdg.configFile."nushell" = {
      source = ./config;
      enable = true;
      recursive = true;
    };

    services.gpg-agent = {
      enable = true;
      enableNushellIntegration = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };

    services.pueue.enable = true;
    programs = {
      nushell = {
        enable = true;
        configFile.text = builtins.readFile ./config.nu;
        envFile.text = builtins.readFile ./env.nu;
        environmentVariables = config.nazarick.home.environmentVariables;
      };

      direnv = {
        enable = true;
        enableNushellIntegration = true;
        nix-direnv.enable = true;
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
        flags = [ "--disable-up-arrow" ];
      };

      nix-index.enable = true;

      zoxide = {
        enable = true;
        enableNushellIntegration = true;
      };

      eza = {
        enable = true;
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

      carapace = {
        enable = true;
        enableNushellIntegration = true;
      };
    };
  };
}
