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
  cfg = config.nazarick.tools.security;
in
{
  options.nazarick.tools.security = {
    enable = mkEnableOption "security";
  };

  config = mkIf cfg.enable {
    nazarick.tools.nushell.module."crypt.nu" = {
      source = ./crypt.nu;
      packages = [ mypkgs.tomb ];
    };
  };
}
