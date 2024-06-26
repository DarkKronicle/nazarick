{
  options,
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.nazarick.workspace.service.kanata;
in
{
  options.nazarick.workspace.service.kanata = {
    enable = mkBoolOpt false "Enable kanta configuration.";
  };
  config = mkIf cfg.enable {
    services.kanata = {
      enable = true;
      package = pkgs.kanata-with-cmd;
      keyboards = {
        k65 = {
          config = builtins.readFile ./k65.kbd;
          devices = [
            "/dev/input/by-id/usb-Corsair_CORSAIR_K65_RGB_MINI_60__Mechanical_Gaming_Keyboard_F5001901605DE321AA3518670D028020-event-kbd"
            "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
          ];
          extraDefCfg = ''
            process-unmapped-keys yes
            danger-enable-cmd yes
            log-layer-changes no
          '';
        };
        kone = {
          config = builtins.readFile ./kone.kbd;
          devices = [
            "/dev/input/by-id/usb-ROCCAT_ROCCAT_Kone_XP_Air_Dongle_AB859AAB61551999-if01-event-kbd"
            "/dev/input/by-id/usb-ROCCAT_ROCCAT_Kone_XP_Air_Dongle_AB859AAB61551999-event-mouse"
          ];
          extraDefCfg = ''
            process-unmapped-keys yes
            danger-enable-cmd yes
            sequence-timeout 1000
            sequence-input-mode hidden-delay-type
            log-layer-changes no
          '';
        };
      };
    };
  };
}
