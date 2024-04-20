{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

with lib;
with lib.nazarick;
let
  cfg = config.nazarick.bundles.messaging;
in
{
  options.nazarick.bundles.messaging = {
    enable = mkEnableOption "Messaing apps";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ nheko ];

    nazarick.apps.vesktop = mkOverride 500 enabled;
  };
}
