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
  cfg = config.nazarick.tools.security;
in
{
  options.nazarick.tools.security = {
    enable = mkEnableOption "security";
  };

  config = mkIf cfg.enable {
    nazarick.tools.nushell.module."crypt.nu" = {
      source = ./crypt.nu;
      packages = with pkgs; [ nazarick.tomb ];
    };
  };
}
