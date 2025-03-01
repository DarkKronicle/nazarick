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

    programs.jujutsu = {
      enable = true;
      settings = {
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
          default-command = "log";
        };
        ui = {
          paginate = "never";
        };
      };
    };
  };
}
