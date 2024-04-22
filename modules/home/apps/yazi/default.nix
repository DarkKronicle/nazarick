{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  cfg = config.nazarick.apps.yazi;

  flavors = pkgs.fetchFromGitHub {
    owner = "yazi-rs";
    repo = "flavors";
    rev = "9cc38276a6d9010de09303c8ff170f4df717ba88";
    hash = "sha256-QpQnOmEeIdUd8OeY3u2BpnfJXz/7v0GbspV475p1gBE=";
  };
in
{
  options.nazarick.apps.yazi = {
    enable = mkEnableOption "Yazi";
  };

  config = mkIf cfg.enable {

    home.file.".config/yazi/flavors/catppuccin-mocha.yazi" = {
      source = "${flavors}/catppuccin-mocha.yazi";
      recursive = true;
    };

    # TODO: probably update to this https://github.com/Rolv-Apneseth/starship.yazi/tree/main
    # will need to properly wrap yazi which will be somewhat annoying
    home.file.".config/yazi/plugins/starship.yazi/init.lua".text = ''
          local save = ya.sync(function(st, cwd, output)
      	    if cx.active.current.cwd == Url(cwd) then
      		    st.output = output
      		    ya.render()
      	    end
          end)

          return {
      	    setup = function(st)
      		    Header.cwd = function()
      			    local cwd = cx.active.current.cwd
      			    if st.cwd ~= cwd then
      				    st.cwd = cwd
      				    ya.manager_emit("plugin", { st._name, args = ya.quote(tostring(cwd)) })
      			    end

      			    return ui.Line.parse(st.output or "")
      		    end
      	    end,

      	    entry = function(_, args)
      		    local output = Command("${pkgs.starship}/bin/starship"):arg("prompt"):cwd(args[1]):env("STARSHIP_SHELL", ""):output()
      		    if output then
      			    save(args[1], output.stdout:gsub("^%s+", ""))
      		    end
      	    end,
          }
    '';

    home.file.".config/yazi/init.lua".text = ''
      require("starship"):setup()
    '';

    programs.yazi = {
      enable = true;
      enableNushellIntegration = true;
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
          cache_dir = "/home/darkkronicle/.cache/yazi";
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
      };
    };
  };
}
