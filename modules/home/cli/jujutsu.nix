{
  lib,
  config,
  mylib,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.cli.jujutsu;
in
{
  options.nazarick.cli.jujutsu = {
    enable = mkEnableOption "Jujutsu";
    userName = mkOpt types.str config.nazarick.cli.git.userName "The name to configure jujutsu with.";
    userEmail =
      mkOpt types.str config.nazarick.cli.git.userEmail
        "The email to configure jujutsu with.";
  };

  config = mkIf cfg.enable {

    home.packages = [
      pkgs.difftastic
    ];

    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
        ui = {
          paginate = "never";
          default-command = "log";
          color = "always";
          diff-formatter = "difftastic";
        };
        merge-tools = {
          "difftastic" = {
            program = lib.getExe pkgs.difftastic;
            diff-args = [
              "--color=always"
              "$left"
              "$right"
            ];
          };
        };
        aliases = {
          # https://gist.github.com/thoughtpolice/8f2fd36ae17cd11b8e7bd93a70e31ad6#file-jjconfig-toml-L154
          tug = [
            "bookmark"
            "move"
            "--from"
            "heads(::@- & bookmarks())"
            "--to"
            "@-"
          ];
        };
        templates = {
          log = "builtin_log_comfortable";
          config_list = "builtin_config_list_detailed";
          draft_commit_description = ''
            concat(
              coalesce(description, default_commit_description, "\n"),
              surround(
                "\nJJ: This commit contains the following changes:\n", "",
                indent("JJ:     ", diff.stat(72)),
              ),
              "\nJJ: ignore-rest\n",
              diff.git(),
            )
          '';
        };
        template-aliases = {
          "format_short_signature(signature)" = "signature.name()";
          "format_timestamp(timestamp)" = "timestamp.ago()";
        };
        git = {
          # https://gist.github.com/thoughtpolice/8f2fd36ae17cd11b8e7bd93a70e31ad6#file-jjconfig-toml-L87
          private-commits = "blacklist()";
        };
        revset-aliases = {
          "wip()" = ''description(glob:"wip:*")'';
          "private()" = ''description(glob:"private:*")'';
          "blacklist()" = ''wip() | private()'';
          # https://github.com/avamsi/dotfiles/blob/7378441fa0a897eb44e62440858887ac234a7b9f/.jjconfig.toml#L8
          "local()" = ''all() ~ ancestors(remote_bookmarks())'';
        };
        colors =
          let
            rosewater = "#f5e0dc";
            flamingo = "#f2cdcd";
            pink = "#f5c2e7";
            mauve = "#cba6f7";
            red = "#f38ba8";
            maroon = "#eba0ac";
            peach = "#fab387";
            yellow = "#f9e2af";
            green = "#a6e3a1";
            teal = "#94e2d5";
            sky = "#89dceb";
            sapphire = "#74c7ec";
            blue = "#89b4fa";
            lavender = "#b4befe";
            text = "#cdd6f4";
            subtext1 = "#bac2de";
            subtext0 = "#a6adc8";
            overlay2 = "#9399b2";
            overlay1 = "#7f849c";
            overlay0 = "#6c7086";
            surface2 = "#585b70";
            surface1 = "#45475a";
            surface0 = "#313244";
            base = "#1e1e2e";
            mantle = "#181825";
            crust = "#11111b";
          in
          {
            "error" = {
              fg = "default";
              bold = true;
            };
            "error_source" = {
              fg = "default";
            };
            "warning" = {
              fg = "default";
              bold = true;
            };
            "hint" = {
              fg = "default";
            };
            "error heading" = {
              fg = "red";
              bold = true;
            };
            "error_source heading" = {
              bold = true;
            };
            "warning heading" = {
              fg = "yellow";
              bold = true;
            };
            "hint heading" = {
              fg = "cyan";
              bold = true;
            };
            "conflict_description" = yellow;
            "conflict_description difficult" = red;
            "commit_id" = green;
            "change_id" = blue;
            # Unique prefixes and the rest for change & commit ids;
            "prefix" = {
              bold = true;
            };
            "rest" = "bright black";
            "divergent rest" = "red";
            "divergent prefix" = {
              fg = "red";
              underline = true;
            };
            "hidden prefix" = "default";
            "author" = mauve;
            "committer" = mauve;
            "timestamp" = subtext0;
            "working_copies" = lavender;
            "bookmark" = mauve;
            "bookmarks" = mauve;
            "local_bookmarks" = lavender;
            "remote_bookmarks" = mauve;
            "tag" = mauve;
            "tags" = mauve;
            "git_ref" = subtext0;
            "git_refs" = subtext0;
            "git_head" = subtext0;
            "divergent" = red;
            "divergent change_id" = red;
            "conflict" = red;
            "empty" = rosewater;
            "placeholder" = red;
            "description placeholder" = flamingo;
            "empty description placeholder" = subtext0;
            "separator" = "bright black";
            "elided" = "bright black";
            "root" = blue;
            "working_copy" = {
              bold = true;
            };
            "working_copy commit_id" = "bright blue";
            "working_copy change_id" = "bright magenta";
            # We do not use bright yellow because of how it looks on xterm's default theme.;
            # https://github.com/jj-vcs/jj/issues/528;
            "working_copy author" = mauve;
            "working_copy committer" = mauve;
            "working_copy timestamp" = sapphire;
            "working_copy working_copies" = green;
            "working_copy bookmark" = mauve;
            "working_copy bookmarks" = mauve;
            "working_copy local_bookmarks" = mauve;
            "working_copy remote_bookmarks" = mauve;
            "working_copy tag" = mauve;
            "working_copy tags" = mauve;
            "working_copy git_ref" = subtext0;
            "working_copy git_refs" = subtext0;
            "working_copy divergent" = maroon;
            "working_copy divergent change_id" = maroon;
            "working_copy conflict" = maroon;
            "working_copy empty" = rosewater;
            "working_copy placeholder" = maroon;
            "working_copy description placeholder" = flamingo;
            "working_copy empty description placeholder" = subtext0;
            "config_list name" = "green";
            "config_list value" = "yellow";
            "config_list source" = "blue";
            "config_list path" = "magenta";
            "config_list overridden" = "bright black";
            "config_list overridden name" = "bright black";
            "config_list overridden value" = "bright black";
            "config_list overridden source" = "bright black";
            "config_list overridden path" = "bright black";
            "diff header" = "yellow";
            "diff empty" = "cyan";
            "diff binary" = "cyan";
            "diff file_header" = {
              bold = true;
            };
            "diff hunk_header" = "cyan";
            "diff removed" = {
              fg = "red";
            };
            "diff added" = {
              fg = "green";
            };
            "diff token" = {
              underline = true;
            };
            "diff modified" = "cyan";
            "diff untracked" = "magenta";
            "diff renamed" = "cyan";
            "diff copied" = "green";
            "diff access-denied" = {
              bg = "red";
            };
            "operation id" = blue;
            "operation user" = mauve;
            "operation time" = subtext0;
            "operation tags" = maroon;
            "operation current_operation" = {
              bold = true;
            };
            "operation current_operation id" = sapphire;
            "operation current_operation user" = "yellow";
            "operation current_operation time" = "bright cyan";
            "operation current_operation tags" = "bright magenta";
            "node elided" = {
              fg = "bright black";
            };
            "node working_copy" = {
              fg = "green";
              bold = true;
            };
            "node current_operation" = {
              fg = "green";
              bold = true;
            };
            "node immutable" = {
              fg = "bright cyan";
              bold = true;
            };
            "node conflict" = {
              fg = "red";
              bold = true;
            };
            "signature display" = "yellow";
            "signature key" = "cyan";
            "signature status good" = "green";
            "signature status unknown" = "yellow";
            "signature status bad" = "red";
            "signature status invalid" = "red";
          };
      };
    };
  };
}
