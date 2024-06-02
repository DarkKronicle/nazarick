{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  cfg = config.nazarick.network.common;
in
{

  imports = mylib.scanPaths ./.;

  options.nazarick.network.common = {
    enable = lib.mkEnableOption "Common network configuration";
  };

  config = lib.mkIf cfg.enable {
    nazarick.network = {
      dnscrypt.enable = lib.mkOverride 450 true;
    };
  };
}
