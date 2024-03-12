{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick; let
  cfg = config.nazarick.system.power;
in {
  options.nazarick.system.power = with types; {
    enable = mkBoolOpt false "Enable power configuration.";
  };
  config = mkIf cfg.enable {
    services.power-profiles-daemon.enable = false;
    services.thermald.enable = true;

    services.tlp = {
      enable = true;
      settings = {
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      };
    };
  };
}
