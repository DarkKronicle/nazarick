{
  options,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOverride;
  inherit (lib.nazarick) mkBoolOpt;

  cfg = config.nazarick.system.hardware;
in
{
  options.nazarick.system.hardware = {
    enable = mkBoolOpt false "Enable misc hardware settings";
    tlp = mkBoolOpt true "Use TLP for power management instead of power-profiles-daemon";
    thermald = mkBoolOpt true "Thermald for heat management (CPU)";
    system76cpu = mkBoolOpt true "Use custom CPU scheduler";
  };
  config = mkIf cfg.enable {
    # mkOverride here so that this can also be disabled, by default plasma enables this
    powerManagement.enable = true;

    services.power-profiles-daemon.enable = mkOverride 900 (!cfg.tlp);
    services.thermald.enable = cfg.thermald;
    services.system76-scheduler.settings.cfsProfiles.enable = cfg.system76cpu;

    services.tlp = mkIf cfg.tlp {
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
