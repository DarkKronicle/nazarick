{
  lib,
  config,
  mylib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) mkIf mkEnableOption;
  inherit (mylib) enabled;

  cfg = config.nazarick.bundles.messaging;
in
{
  options.nazarick.bundles.messaging = {
    enable = mkEnableOption "Messaing apps";
  };

  config = mkIf cfg.enable {

    nazarick.apps = {
      vesktop = lib.mkOverride 500 enabled;
      nheko = lib.mkOverride 500 enabled;
    };
  };
}
