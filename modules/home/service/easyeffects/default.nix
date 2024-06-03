{
  lib,
  config,
  mylib,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.service.easyeffects;
in
{
  options.nazarick.service.easyeffects = {
    enable = mkEnableOption "EasyEffects";
  };

  config = mkIf cfg.enable {
    services.easyeffects = {
      enable = true;
      package = pkgs.easyeffects;

      # Does not work, have to do the command separately, a few seconds later
      # https://github.com/wwmm/easyeffects/issues/3010
      # preset = "voice";
    };

    systemd.user.services.easyeffects = {
      Service = {
        # This service hangs on system shutdown fairly frequently
        TimeoutSec = "10";
      };
    };

    dconf.settings."com/github/wwmm/easyeffects" = {
      "process-all-inputs" = true;
    };

    # Load preset after easyeffects has started up
    xdg.configFile."easyeffects/input/voice.json".source = ./voice.json;
    systemd.user.services."easyeffects-load" = {
      Unit = {
        Description = "Load easyeffects settings";
        # Requires = [ "easyeffects.service" ];
        After = [ "easyeffects.service" ];
      };

      Install.RequiredBy = [ "easyeffects.service" ];

      Service = {
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
        ExecStart = "${pkgs.easyeffects}/bin/easyeffects -l voice";
        Type = "oneshot";
      };
    };
  };
}
