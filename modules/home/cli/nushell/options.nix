{
  pkgs,
  config,
  lib,
  mypkgs,
  pkgs-unstable,
  inputs,
  system,
  ...
}:
let
  inherit (lib) types mkIf mkOption;

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

  configContent = pkgs.substitute {
    src = ./config.nu;
    # TODO: Make this a bit easier to add to
    substitutions = [
      "--replace-fail"
      "@THEME@"
      "${pkgs.nu_scripts}/share/nu_scripts/themes/nu-themes/catppuccin-mocha.nu"
      "--replace-fail"
      "@TASK@"
      "${pkgs.nu_scripts}/share/nu_scripts/modules/background_task/task.nu"
      "--replace-fail"
      "@KITTY_PROTOCOL@"
      "${if cfg.useKittyProtocol then "true" else "false"}"
      "--replace-fail"
      "@NIX_SMALL_DB@"
      (pkgs.linkFarm "nix-index-small-database" {
        files = inputs.nix-index-database.packages.${system}.nix-index-small-database;
      })
    ];
  };

  # TODO: make this config option, also make sure to have de-duplication
  plugins = [
    # "${mypkgs.nushell_plugin_explore}/bin/nu_plugin_explore"
    # "${mypkgs.nushell_plugin_regex}/bin/nu_plugin_regex"
    "${pkgs-unstable.nushellPlugins.skim}/bin/nu_plugin_skim"
    # "${pkgs-unstable.nushellPlugins.dbus}/bin/nu_plugin_dbus"
    # "${mypkgs.nushell_plugin_hashes}/bin/nu_plugin_hashes"
    # "${mypkgs.nushell_plugin_json_path}/bin/nu_plugin_json_path"
    # "${mypkgs.nushell_plugin_plotters}/bin/nu_plugin_plotters"
    "${pkgs-unstable.nushellPlugins.polars}/bin/nu_plugin_polars"
  ];
in
{
  options.nazarick.cli.nushell = {

    module = lib.mkOption {
      type = types.attrsOf moduleType;
      default = { };
    };

    use = lib.mkOption {
      type = types.listOf types.path;
      default = [ ];
    };

    source = lib.mkOption {
      type = types.listOf types.path;
      default = [ ];
    };

    useKittyProtocol = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Enable kitty protocol, it will be disabled if within zellij";
    };

    alias = lib.mkOption { type = types.attrsOf types.str; };
  };

  config = mkIf cfg.enable {

    home.packages = (
      with pkgs;
      [
        # TODO: move this
        skim
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

    xdg.configFile."nushell" = {
      source = ./config;
      enable = true;
      recursive = true;
    };

    programs.nushell = {
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
        ++ [ (builtins.readFile configContent) ]
        ++ [ (lib.concatStringsSep "\n" (lib.forEach cfg.source (file: "source ${file}"))) ]
        ++ [
          (lib.concatStringsSep "\n" (
            lib.mapAttrsToList (name: command: "alias ${name} = ${command}") cfg.alias
          ))
        ]
      );
      envFile.text = builtins.readFile ./env.nu;
      # IMPORTANT: https://github.com/nix-community/home-manager/issues/1011#issuecomment-1624977707
      # Environment variables are a weird thing
      # The main issue is that these variables will be set correctly on the graphical session,
      # but when a shell is created things get jank (it sources /etc/profile) (I think)
      # this fixes it :)
      environmentVariables = config.home.sessionVariables;
    };
  };
}
