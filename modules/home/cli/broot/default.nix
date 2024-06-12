{
  pkgs,
  config,
  lib,
  ...
}:
let
  broot-choose-file = pkgs.writeTextFile {
    name = "br-choose";
    destination = "/share/nushell/br-choose.nu";
    text = ''
      source ${
        pkgs.runCommand "br.nushell" {
          nativeBuildInputs = [ pkgs.broot ];
        } "broot --print-shell-function nushell > $out"
      }

      alias bb = br --conf ${./editor.hjson}
      alias br-choose = broot --conf ${./chooser.hjson}

      def _br_fzf_goto [] {
        let file = br-choose
        if ($file | is-empty) {
          return "."
        }
        let real_file = if (($file | path type) != "dir") {
          $file | path dirname
        } else {
          $file
        }
        $real_file
      }

      def _br_fzf_select [] {
        let current = commandline
        let cursor = commandline get-cursor
        let words = ($current | split row " " | each {|x| { word: $x, length: ($x | str length) }})
        mut i = 0
        mut index = 0
        mut current_word = 0
        for word in $words {
        let length = $word.length
        $current_word = $index
        if (($i + $length) > $cursor) {
          break
        }
        $i = $i + $length
          $index = $index + 1
        }
        let file = br-choose -c ($words | get $current_word | get word)
        if ($file | is-empty) {
          return
        }
        let newline = ($words.word | drop $current_word | insert $current_word $file | str join " ")
        commandline edit --replace $newline
        commandline set-cursor ($i + (($file | str length) + 1))
      }


      # Following structure taken from atuin

      $env.config = ($env.config | default [] keybindings)

      $env.config = (
          $env.config | upsert keybindings (
            $env.config.keybindings
            | append {
              name: broot-choose-file
              modifier: control
              keycode: char_f
              mode: [emacs, vi_normal, vi_insert]
              event: { send: executehostcommand cmd: _br_fzf_select }
            }
        )
      )

      $env.config = (
          $env.config | upsert keybindings (
            $env.config.keybindings
            | append {
              name: broot-choose-goto
              modifier: control
              keycode: char_g
              mode: [emacs, vi_normal, vi_insert]
              event: { send: executehostcommand cmd: "cd (_br_fzf_goto)" }
            }
        )
      )
    '';
  };

  cfg = config.nazarick.cli.broot;
in
{
  options.nazarick.cli.broot = {
    enable = lib.mkEnableOption "broot";
  };

  config = lib.mkIf cfg.enable {

    nazarick.cli.nushell.source = [ "${broot-choose-file}/share/nushell/br-choose.nu" ];

    programs.broot = {
      enable = true;
      enableNushellIntegration = false;
      settings = {
        imports = [ "${pkgs.broot.src}/resources/default-conf/skins/catppuccin-mocha.hjson" ];

        modal = true;
        initial_mode = "input";
        quit_on_last_cancel = true;

        enable_kitty_keyboard = lib.mkForce true;
        default_flags = "-Ihg"; # show hidden files and git status
        icon_theme = "nerdfont";

        special_paths = {
          "/nix" = {
            sum = "never";
            list = "never";
          };
          ".config" = {
            show = "always";
          };
          ".cache" = {
            list = "never";
          };
          ".local" = {
            show = "always";
          };
        };
      };
    };
  };
}
