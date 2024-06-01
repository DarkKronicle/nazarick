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
  cfg = config.nazarick.system.boot;
in
{
  options.nazarick.system.boot = {
    grub = mkBoolOpt false "Enable grub bootloader.";
  };
  config = mkIf cfg.grub {
    boot.loader.systemd-boot = {
      enable = false;
      # consoleMode = "max";
    };
    boot.loader = {
      timeout = 0;
      grub = {
        timeoutStyle = "countdown";
        enable = true;
        splashImage = null;
        configurationLimit = 50;
        # useOSProber = true;
        efiSupport = true;
        device = "nodev";
        # efiInstallAsRemovable = true;
        # extraEntriesBeforeNixOS = true;
        extraEntries = ''
            menuentry "Reboot" {
              reboot
            }
          menuentry "Poweroff" {
            halt
          }
        '';
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };
}
