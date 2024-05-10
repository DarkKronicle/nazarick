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

    nazarick.apps = {
      vesktop = mkOverride 500 enabled;
      nheko = mkOverride 500 enabled;
    };
  };
}
