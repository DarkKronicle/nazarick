{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib)
    types
    mkEnableOption
    mkIf
    mkOption
    literalExpression
    ;

  mkNuFile =
    name: contents:
    pkgs.writeTextFile {
      name = name;
      text = contents;
      destination = "/share/nushell/${name}";
    };

  moduleType = types.submodule (
    { config, ... }:
    {
      options = {
        source = mkOption {
          type = types.path;
          default = null;
          description = ''
            Path of the nushell file to use.
          '';
        };

        packages = lib.mkOption {
          type = types.nullOr (types.listOf types.package);
          default = null;
        };
      };
    }
  );

  cfg = config.nazarick.cli.nushell;
in
{
  options.nazarick.cli.nushell = {
    enable = mkEnableOption "Nushell";

    module = lib.mkOption {
      type = types.attrsOf moduleType;
      default = null;
    };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      # TODO: move this
      devenv
    ];

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

    programs.ssh.addKeysToAgent = "yes";

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
        configFile.text = lib.concatStringsSep "\n" (
          (lib.mapAttrsToList (
            name: value:
            let
              mkNuList =
                items: "[ ${lib.concatStringsSep "," (lib.forEach items (content: "\"${content}\" "))} ]";
              patchText =
                source: prepend: append:
                pkgs.substitute {
                  src = source;
                  substitutions = [
                    "--replace-fail"
                    "@NIX_PATH_PREPEND@"
                    prepend
                    "--replace-fail"
                    "@NIX_PATH_APPEND@"
                    append
                  ];
                };
              file = mkNuFile name (builtins.readFile (patchText (value.source) (mkNuList value.packages) "[]"));
            in
            "use ${file}/share/nushell/${name}"
          ) cfg.module)
          ++ [ (builtins.readFile ./config.nu) ]
        );
        envFile.text = builtins.readFile ./env.nu;
        # IMPORTANT: https://github.com/nix-community/home-manager/issues/1011#issuecomment-1624977707
        # Environment variables are a weird thing
        # The main issue is that these variables will be set correctly on the graphical session,
        # but when a shell is created things get jank (it sources /etc/profile) (I think)
        # this fixes it :)
        environmentVariables = config.home.sessionVariables;
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

      zoxide = {
        enable = true;
        enableNushellIntegration = true;
      };

      eza = {
        enable = true;
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
