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

    home.packages = [
      mypkgs.script-nux
      mypkgs.script-f
      # Textual currently broke
      # mypkgs.script-ai
      mypkgs.script-swu
      mypkgs.script-nuru
      mypkgs.script-cache
      mypkgs.script-util
      mypkgs.script-xpress
      mypkgs.script-crypt
      mypkgs.script-stl
      mypkgs.script-tk

      pkgs.devenv
    ];

    nazarick.cli.nushell.source = [
      "${pkgs.nu_scripts}/share/nu_scripts/custom-completions/man/man-completions.nu"
    ];

    systemd.user.tmpfiles.rules = [
      "L /home/${config.home.username}/.local/share/nushell - - - - /home/${config.home.username}/.local/state/home-manager/gcroots/current-home/home-path/share/nushell"
    ];

    programs.nushell.extraConfig = ''
      use ${pkgs.nu_scripts}/share/nu_scripts/nu-hooks/nu-hooks/nuenv/hook.nu [ "nuenv allow", "nuenv disallow" ]
      $env.config.hooks.env_change = $env.config.hooks.env_change | upsert PWD ([(use ${pkgs.nu_scripts}/share/nu_scripts/nu-hooks/nu-hooks/nuenv/hook.nu; hook setup)] | append ($env.config.hooks | get PWD?))

      def grasp-heart [--restart(-r)] {
        let value = do { sudo -E ${pkgs.tomb}/bin/tomb close all | tee { print } } | complete
        if ($value.exit_code != 0) {
          if ("There is no open tomb to be closed" not-in $value.stderr) {
            print $value.stderr
            return;
          }
        }
        if ($restart) {
          systemctl reboot
        } else {
          systemctl poweroff
        }
      }
    '';

    nazarick.cli.nushell.alias = {
      "icat" = "kitten icat";
      "zz" = "systemd-inhibit sleep infinity";
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
