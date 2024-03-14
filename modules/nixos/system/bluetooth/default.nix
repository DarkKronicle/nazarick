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
  cfg = config.nazarick.system.bluetooth;
in
{
  options.nazarick.system.bluetooth = with types; {
    enable = mkBoolOpt false "Enable bluetooth support.";
    disable_hsp = mkBoolOpt false "Disable handsfree support";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
        };
      };
    };
    services.pipewire.wireplumber = mkIf cfg.disable_hsp {
      configPackages = (
        pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
          bluez_monitor.properties = {
            ["bluez5.roles"] = "[ a2dp_sink ]",
            ["bluez5.hfphsp-backend"] = "none",
          }
          bluez_monitor.rules = {
            {
              apply_properties = {
                ["bluez5.auto-connect"] = "[ a2dp_sink ]",
                ["bluez5.hw-volume"] = "[ a2dp_sink ]",
              },
            },
          }
        ''
      );
    };
  };
}
