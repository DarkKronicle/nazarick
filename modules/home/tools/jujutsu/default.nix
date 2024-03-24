{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  user = config.nazarick.user;
  cfg = config.nazarick.tools.jujutsu;
in
{
  options.nazarick.tools.jujutsu = {
    enable = mkEnableOption "Jujutsu";
    userName = mkOpt types.str "" "The name to configure jujutsu with.";
    userEmail = mkOpt types.str "" "The email to configure jujutsu with.";
  };

  config = mkIf cfg.enable {

    nazarick.tools.jujutsu = {
      userName = lib.mkDefault config.nazarick.tools.git.userName;
      userEmail = lib.mkDefault config.nazarick.tools.git.userEmail;
    };

    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
      };
    };
  };
}
