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
    ./plugins/bookmarks.nix
  ] readPlugin;
in
{
  options.nazarick.tui.yazi = {
    enable = mkEnableOption "Yazi";
  };

  config = mkIf cfg.enable {

    programs.yazi = {
      enable = true;
      enableNushellIntegration = false;
      flavors = {
        "catppuccin-mocha" = "${flavors}/catppuccin-mocha.yazi";
      };

      initLua = lib.concatStringsSep "\n" (
        lib.forEach (builtins.filter (plugin: builtins.hasAttr "init_lua_text" plugin) plugins) (
          plugin: plugin.init_lua_text
        )
      );

      plugins = lib.mkMerge (
        lib.forEach plugins (plugin: {
          "${plugin.name}" = "${plugin.package}/share/yazi/plugins/${plugin.name}.yazi";
        })
      );

      keymap = {
        mgr.prepend_keymap = [
          {
            on = "!";
            run = ''shell "$SHELL" --block'';
            desc = "Open shell here";
          }
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
          {
            on = [ "M" ];
            run = "plugin bookmarks --args=save";
            desc = "Save current position as a bookmark";
          }
          {
            on = [ "'" ];
            run = "plugin bookmarks --args=jump";
            desc = "Jump to a bookmark";
          }
          {
            on = [
              "B"
              "d"
            ];
            run = "plugin bookmarks --args=delete";
            desc = "Delete a bookmark";

          }
          {
            on = [
              "B"
              "D"
            ];
            run = "plugin bookmarks --args=delete_all";
            desc = "Delete all bookmarks";
          }
        ];
      };
      theme = {
        mgr = {
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
        mgr = {
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
