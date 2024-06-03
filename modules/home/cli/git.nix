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

  user = config.nazarick.user;
  cfg = config.nazarick.cli.git;
in
{
  options.nazarick.cli.git = {
    enable = mkEnableOption "Git";
    userName = mkOpt types.str "" "The name to configure git with.";
    userEmail = mkOpt types.str "" "The email to configure git with.";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      inherit (cfg) userName userEmail;
      ignores = [
        ".Trash-*"

        ".DS_Store"
        ".DS_Store?"
        "._*"
        ".Spotlight-V100"
        ".Trashes"
        "ehthumbs.db"
        "Thumbs.db"
      ];
      extraConfig = {
        credential.helper = [
          "cache --timeout 60000"
          "oauth"
        ];
        init = {
          defaultBranch = "main";
        };
      };
      signing = {
        key = "D07B541F73FBBA18D11B2F63D7592266239CD59C";
        signByDefault = true;
      };

      # A syntax-highlighting pager in Rust(2019 ~ Now)
      delta = {
        enable = true;
        options = {
          diff-so-fancy = true;
          line-numbers = true;
          true-color = "always";
          # features => named groups of settings, used to keep related settings organized
          # features = "";
        };
      };
    };
  };
}
