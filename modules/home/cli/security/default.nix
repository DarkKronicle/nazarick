{
  lib,
  config,
  mylib,
  pkgs,
  mypkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  user = config.nazarick.user;
  cfg = config.nazarick.cli.security;
in
{
  options.nazarick.cli.security = {
    enable = mkEnableOption "security";
  };

  config = mkIf cfg.enable {
    nazarick.cli.nushell.module."crypt.nu" = {
      source = ./crypt.nu;
      packages = [ mypkgs.tomb ];
    };
  };
}
