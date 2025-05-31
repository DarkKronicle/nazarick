{
  options,
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkOverride;
  inherit (mylib) mkBoolOpt;

  cfg = config.nazarick.system.misc;
in
{
  options.nazarick.system.misc = {
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

        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;

        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        PLATFORM_PROFILE_ON_AC = "balance_performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;
      };
    };
  };
}
