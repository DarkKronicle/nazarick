{
  lib,
  config,
  pkgs,
  mylib,
  mypkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.workspace.service.jellyfin;
in
{
  options.nazarick.workspace.service.jellyfin = {
    enable = mkEnableOption "Jellyfin";
    startAfter = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Units to start after";
    };
    bindsTo = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Units to bind to after";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."borg/repository" = { };
    sops.secrets."borg/wifi" = { };
    sops.secrets."borg/password" = { };

    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };

    systemd.services.jellyfin.after = cfg.startAfter;
    systemd.services.jellyfin.bindsTo = cfg.bindsTo;
  };
}
