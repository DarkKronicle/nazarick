{
  lib,
  config,
  pkgs,
  mylib,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  toml = pkgs.formats.toml { };

  cfg = config.nazarick.service.spotifyd;

  spotifydConf = toml.generate "spotifyd.toml" {
    global = {
      # username_cmd = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."spotifyd/username".path}";
      # password_cmd = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."spotifyd/password".path}";

      # Set up credentials by yourself
      # https://github.com/Spotifyd/spotifyd/issues/1293A
      cache_path = "/home/${config.home.username}/.cache/spotifyd";
      username_cmd = "${pkgs.nushell}/bin/nu -c 'open /home/${config.home.username}/.cache/spotifyd/credentials.json | get username'";
      use_mpris = true;
      dbus_type = "session";
      initial_volume = "80";
      volume_controller = "softvol";
      backend = "pulseaudio";
      device_name = "Spotifyd@tabula";
    };
  };
in
{
  options.nazarick.service.spotifyd = {
    enable = mkEnableOption "spotifyd";
  };

  config = mkIf cfg.enable {
    sops.secrets."spotifyd/username" = { };
    sops.secrets."spotifyd/password" = { };

    systemd.user.services.spotifyd = {

      Unit = {
        Description = "spotify daemon";
        After = [ "sops-nix.service" ];
      };

      Service = {
        ExecStart = "${pkgs.spotifyd}/bin/spotifyd --no-daemon --config-path ${spotifydConf}";
        Environment = [
          "DISPLAY=:1"
          "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus"
        ];
        Restart = "always";
        RestartSec = 12;
      };
    };
  };
}
