{
  lib,
  mylib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.tui.yazi;

  flavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "9cc38276a6d9010de09303c8ff170f4df717ba88";
    hash = "sha256-QpQnOmEeIdUd8OeY3u2BpnfJXz/7v0GbspV475p1gBE=";
  };

  readPlugin = file: pkgs.callPackage file { };
  # TODO: Cursed, do something about this
  plugins = lib.forEach [
    ./plugins/starship.nix
    ./plugins/hexyl.nix
    ./plugins/ouch.nix
    ./plugins/exiftool.nix
    ./plugins/broot.nix
  ] readPlugin;
in
{
  options.nazarick.tui.yazi = {
    enable = mkEnableOption "Yazi";
  };

  config = mkIf cfg.enable {

    # TODO: Use package override to declare yazi when it's fixed
    xdg.configFile = lib.mkMerge (
      (lib.forEach plugins (plugin: {
        "yazi/plugins/${plugin.name}" = {
          enable = true;
          recursive = true;
          source = "${plugin.package}/share/yazi/plugins/${plugin.name}";
        };
      }))
      ++ [
        {
          "yazi/init.lua" = {
            enable = true;
            # This can probably be automatically concatenated with home manager, but /shrug. Good practice for me.
            text = lib.concatStringsSep "\n" (
              lib.forEach (builtins.filter (plugin: builtins.hasAttr "init_lua_text" plugin) plugins) (
                plugin: plugin.init_lua_text
              )
            );
          };
        }
        {
          "yazi/flavors/catppuccin-mocha.yazi" = {
            enable = true;
            source = "${flavors}/catppuccin-mocha.yazi";
            recursive = true;
          };
        }
      ]
    );

    programs.yazi = {
      enable = true;
      enableNushellIntegration = false;
      keymap = {
        manager.prepend_keymap = [
          {
            on = [
              "<Space>"
              "y"
            ];
            run = [
              "yank"
              ''shell --confirm 'for path in "$@"; do echo "file://$path"; done | wl-copy -t text/uri-list' ''
            ];
            desc = "Copy selection";
          }
          {
            on = [
              "<Space>"
              "d"
            ];
            run = [
              # https://github.com/sxyazi/yazi/discussions/327
              # ''shell '${pkgs.xdragon}/bin/dragon -x -i -T "$1"' --confirm''
              ''shell '${pkgs.ripdrag}/bin/ripdrag "$@" -x -n 2>/dev/null &' --confirm''
            ];
            desc = "Drag and drop selection";
          }
          {
            on = [ "b" ];
            run = [ "plugin broot" ];
            desc = "Broot fuzzy find";
          }
        ];
      };
      theme = {
        manager = {
          border_style = {
            fg = "darkgray";
          };
        };
        flavor = {
          use = "catppuccin-mocha";
        };
      };
      settings = {
        preview = {
          cache_dir = "${config.home.homeDirectory}/.cache/yazi";
          max_width = 1024;
          max_height = 1920;
        };
        opener = {
          open = [
            {
              run = ''${./open.nu} "$@"'';
              desc = "Open";
              for = "linux";
              block = false;
            }
          ];
        };
        log = {
          enabled = true;
        };
        manager = {
          linemode = "size";
          show_hidden = true;
          sort_by = "natural";
          sort_dir_first = true;
        };
        plugin = {
          prepend_previewers = [
            # Archive previewer
            {
              mime = "application/*zip";
              run = "ouch";
            }
            {
              mime = "application/x-tar";
              run = "ouch";
            }
            {
              mime = "application/x-bzip2";
              run = "ouch";
            }
            {
              mime = "application/x-7z-compressed";
              run = "ouch";
            }
            {
              mime = "application/x-rar";
              run = "ouch";
            }
            {
              mime = "application/x-xz";
              run = "ouch";
            }
            {
              mime = "audio/*";
              run = "exifaudio";
            }
          ];
          append_previewers = [
            {
              name = "*";
              run = "hexyl";
            }
          ];
        };
      };
    };
  };
}
