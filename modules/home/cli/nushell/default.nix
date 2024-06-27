{
  lib,
  config,
  pkgs,
  inputs,
  mypkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;

  cfg = config.nazarick.cli.nushell;

in
# TODO: make this config option, also make sure to have de-duplication
{
  imports = [ ./options.nix ];

  options.nazarick.cli.nushell = {
    enable = mkEnableOption "Nushell";
  };

  config = mkIf cfg.enable {

    home.packages = (
      with pkgs;
      [
        # TODO: move this
        devenv
      ]
    );

    nazarick.cli.nushell.source = [
      "${pkgs.nu_scripts}/share/nu_scripts/custom-completions/man/man-completions.nu"
    ];

    nazarick.cli.nushell.alias = {
      "icat" = "kitten icat";
      "zz" = "systemd-inhibit sleep infinity";
    };

    programs.ssh.addKeysToAgent = "yes";

    services.gpg-agent = {
      enable = true;
      enableNushellIntegration = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };

    services.pueue.enable = true;
    programs = {

      direnv = {
        enable = true;
        enableNushellIntegration = true;
        nix-direnv.enable = true;
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

      zoxide = {
        enable = true;
        enableNushellIntegration = true;
      };

      # TODO: switch to tlrc
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
