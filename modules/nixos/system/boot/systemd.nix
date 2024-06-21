{
  options,
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;
  cfg = config.nazarick.system.boot.systemd-boot;
in
{
  options.nazarick.system.boot.systemd-boot = {
    enable = mkBoolOpt false "Enable systemd-boot bootloader.";
  };
  config = mkIf cfg.enable {
    boot.loader.systemd-boot = {
      enable = true;
      # consoleMode = "max";
    };
    boot.loader = {
      timeout = 0;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };
}
