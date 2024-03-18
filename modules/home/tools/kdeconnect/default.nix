{ lib, config, ... }:

let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.nazarick.tools.kdeconnect;
in
{
  options.nazarick.tools.kdeconnect = {
    enable = mkEnableOption "KDE-Connect";
  };

  config = mkIf cfg.enable {
    services.kdeconnect = {
      enable = true;
      # indicator = true; # only if non-kde
    };
  };
}
