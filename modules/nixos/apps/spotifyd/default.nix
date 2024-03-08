{ lib, config, pkgs, inputs, ... }:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  toml = pkgs.formats.toml {};

  cfg = config.nazarick.apps.spotifyd;

  spotifydConf = toml.generate "spotifyd.toml" {
    global = {
      username_cmd = "cat ${config.sops.secrets."spotifyd/username".path}";
      password_cmd = "cat ${config.sops.secrets."spotifyd/password".path}";
      use_mpris = true;
      dbus_type = "session";
      initial_volume = "80";
      volume_controller = "softvol";
      backend = "pulseaudio";
      device_name = "tabula-spotifyd";
    };
  };
in
{
  options.nazarick.apps.spotifyd = {
    enable = mkEnableOption "spotifyd";
  };

  config = mkIf cfg.enable {
# 
    # services.spotifyd = {
      # enable = true;
      # settings = {
        # global = {
          # username_cmd = "cat ${config.sops.secrets."spotifyd/username".path}";
          # password_cmd = "cat ${config.sops.secrets."spotifyd/password".path}";
          # use_mpris = true;
          # dbus_type = "session";
          # initial_volume = "80";
          # volume_controller = "softvol";
          # backend = "pulseaudio";
          # device = "tabula-spotifyd";
        # };
      # };
    # };

    systemd.user.services.spotifyd = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" "sound.target" ];
      environment.SHELL = "/bin/sh";
      description = "spotify daemon";
 
      serviceConfig = {
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
