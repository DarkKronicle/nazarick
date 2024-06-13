{
  lib,
  config,
  pkgs,
  inputs,
  mypkgs,
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

  # TODO: make this config option, also make sure to have de-duplication
  plugins = [ "${mypkgs.nushell_plugin_explore}/bin/nu_plugin_explore" ];
in
{
  options.nazarick.cli.nushell = {
    enable = mkEnableOption "Nushell";

    module = lib.mkOption {
      type = types.attrsOf moduleType;
      default = null;
    };

    use = lib.mkOption {
      type = types.listOf types.path;
      default = [ ];
    };
    source = lib.mkOption {
      type = types.listOf types.path;
      default = [ ];
    };
  };

  config = mkIf cfg.enable {

    home.packages = (
      with pkgs;
      [
        # TODO: move this
        devenv
      ]
    );

    systemd.user.services = {
      nushell-setup = {
        Unit = {
          Description = "Set up nushell environment";
          # https://github.com/nix-community/home-manager/issues/3865
          X-SwitchMethod = "restart";
          X-Restart-Triggers = plugins;
        };

        Service = {
          Type = "oneshot";
          ExecStart =
            let
              file = pkgs.writeTextFile {
                name = "nu-environment-setup.nu";
                text = ''
                  # Make atuin history nushell history
                  ATUIN_SESSION='blank' ${pkgs.atuin}/bin/atuin history list --cmd-only | split row '\n' | reverse | uniq | reverse | save -f ${config.home.homeDirectory}/.config/nushell/history.txt

                  # Remove each plugin
                  plugin list | get name | each {|x| (plugin rm $x)}

                  ${lib.concatStringsSep "\n" (lib.forEach plugins (plugin: "plugin add ${plugin}"))}
                '';
              };
            in
            ''${pkgs.nushell}/bin/nu ${file}'';
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
          ++ [ (lib.concatStringsSep "\n" (lib.forEach cfg.use (file: "use ${file}"))) ]
          ++ [ (builtins.readFile ./config.nu) ]
          ++ [ (lib.concatStringsSep "\n" (lib.forEach cfg.source (file: "source ${file}"))) ]
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