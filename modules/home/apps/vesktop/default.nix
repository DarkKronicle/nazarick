{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.nazarick.apps.vesktop;
in
{
  options.nazarick.apps.vesktop = {
    enable = mkEnableOption "Vesktop";
  };

  config = mkIf cfg.enable {

    # TODO: Add config into here
    home.packages = with pkgs; [
      # https://github.com/Faupi/nixos-configs/blob/aea7c558de0e51443ea6d9bce4ba476ba638fed7/home-manager/cfgs/shared/vesktop/default.nix#L9-L18
      (vesktop.overrideAttrs (oldAttrs: {
        desktopItems = [
          (pkgs.makeDesktopItem {
            name = "vesktop";
            desktopName = "Vesktop";
            icon = "discord";
            startupWMClass = "Vesktop";
            exec = "vesktop %U";
            keywords = [
              "discord"
              "vencord"
              "electron"
              "chat"
            ];
            categories = [
              "Network"
              "InstantMessaging"
              "Chat"
            ];
          })
        ];
      }))
    ];
  };
}
