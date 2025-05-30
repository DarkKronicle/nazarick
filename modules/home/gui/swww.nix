{
  pkgs,
  lib,
  mylib,
  config,
  ...
}:
let
  cfg = config.nazarick.gui.swww;

  swwwScriptContent = # nu
    ''
      #!/usr/bin/env nu
      let path = if ("SESSION_CONTEXT" in $env and $env.SESSION_CONTEXT == "school") {
        '${cfg.schoolWallpaperPath}'
      } else {
        '${cfg.wallpaperPath}'
      }

      let displays = ${pkgs.swww}/bin/swww query | split row (char newline) | split column ':' | get column1

      for display in $displays {
        let choice = ls $path | shuffle | get 0.name
        ${pkgs.swww}/bin/swww img -o $display --transition-fps 60 $choice
      }
    '';

  swwwScript = mylib.writeScript pkgs "swww-switch" swwwScriptContent;
in
{
  options.nazarick.gui.swww = {
    enable = lib.mkEnableOption "swww";

    calendar = lib.mkOption {
      type = lib.types.str;
      description = "calendar timestamp to switch wallpaper";
      default = "*-*-* *:00/30:00";
    };

    wallpaperPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      description = "path for wallpaper";
    };

    schoolWallpaperPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      description = "path for wallpaper at school";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.swww
      swwwScript
    ];

    systemd.user.services.swww-daemon = {
      Unit = {
        After = [ "graphical-session.target" ];
        Requires = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        Type = "exec";
        ExecStart = "${pkgs.swww}/bin/swww-daemon";
      };
    };

    systemd.user.timers."swww-switch" = {

      Timer = {
        OnCalendar = cfg.calendar;
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

    };

    systemd.user.services."swww-switch" = {

      # Install = {
      # WantedBy = [ "graphical-session.target" ];
      # };

      Unit = {
        Description = "rotate swww wallpaper";
        After = [ "swww-daemon.service" ];
        Requires = [ "swww-daemon.service" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.nushell}/bin/nu ${swwwScript}/bin/swww-switch";
      };

    };

  };

}
