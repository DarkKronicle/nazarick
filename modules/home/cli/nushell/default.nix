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

    home.packages = ([
      mypkgs.scripts.nux
      mypkgs.scripts.swu
      mypkgs.scripts.cache
      mypkgs.scripts.util
      mypkgs.scripts.xpress
    ]);

    nazarick.cli.nushell.source = [
      "${pkgs.nu_scripts}/share/nu_scripts/custom-completions/man/man-completions.nu"
    ];

    systemd.user.tmpfiles.rules = [
      "L /home/${config.home.username}/.local/share/nushell - - - - /home/${config.home.username}/.local/state/home-manager/gcroots/current-home/home-path/share/nushell"
    ];

    programs.nushell.extraConfig = ''
      use ${pkgs.nu_scripts}/share/nu_scripts/nu-hooks/nu-hooks/nuenv/hook.nu [ "nuenv allow", "nuenv disallow" ]
      $env.config.hooks.env_change.PWD = (use ${pkgs.nu_scripts}/share/nu_scripts/nu-hooks/nu-hooks/nuenv/hook.nu; hook setup)
    '';

    nazarick.cli.nushell.alias = {
      "icat" = "kitten icat";
      "zz" = "systemd-inhibit sleep infinity";
      "grasp-heart" = "systemctl poweroff";
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
