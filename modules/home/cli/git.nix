{
  lib,
  config,
  mylib,
  pkgs,
  myvars,
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

    home.packages = with pkgs; [ git-credential-oauth ];

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
        # credential.helper = [
        # "cache --timeout 60000"
        # "oauth"
        # ];
        core.sshCommand = "ssh -i ~/.ssh/id_tabula";
        init = {
          defaultBranch = "main";
        };
      };
      includes = [
        {
          condition = "hasconfig:remote.*.url:git@gitlab.com/DarkKronicle/nix-sops.git";
          contents = {
            core.sshCommand = "ssh -i ~/.ssh/id_nazarick";
          };
        }
        {
          condition = myvars.personal-git.condition;
          contents = {
            core.sshCommand = "ssh -i ${myvars.personal-git.ssh}";
            contents = {
              name = myvars.personal-git.name;
              email = myvars.personal-git.email;
            };
            commit = {
              gpgSign = false;
            };
          };
        }
      ];
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
