{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick;
let
  cfg = config.nazarick.system.boot;
in
{
  options.nazarick.system.boot = with types; {
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
