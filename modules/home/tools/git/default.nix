{ lib, config, pkgs, ... }:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  user = config.nazarick.user;
  cfg = config.nazarick.tools.git;
in
{
  options.nazarick.tools.git = {
    enable = mkEnableOption "Git";
    userName = mkOpt types.str "" "The name to configure git with.";
    userEmail = mkOpt types.str "" "The email to configure git with.";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      inherit (cfg) userName userEmail;
      extraConfig = {
        credential.helper = [
          "cache --timeout 60000"
          "oauth"
        ];
        init = { defaultBranch = "main"; };
      };
      signing = {
        key = "D07B541F73FBBA18D11B2F63D7592266239CD59C";
        signByDefault = true;
      };
    };
  };
}
