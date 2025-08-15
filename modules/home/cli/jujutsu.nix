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
        };
      };
    };
  };
}
