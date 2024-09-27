{
  pkgs,
  lib,
  config,
  ...

}:
let
  cfg = config.nazarick.system.btrbk;
in
{
  options.nazarick.system.btrbk = {
    enable = lib.mkEnableOption "btrbk";

    rootDirectory = lib.mkOption {
      description = "Path to the pool/root directory";
      default = "/btr";
      type = lib.types.str;
    };

    subvolume = lib.mkOption {
      description = "Path to the pool/root directory";
      default = { };
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf cfg.enable {
    services.btrbk.instances."btrbk" = {
      onCalendar = "00/2:00"; # every 2 hours
      settings = {
        snapshot_preserve_min = "1d"; # keep for 1 day
        snapshot_preserve = "12h 14d"; # keep 12 backups of hourly backups, and 14 daily backups
        target_preserve_min = "1d";
        target_preserve = "12h 14d";
        snapshot_dir = "${cfg.rootDirectory}/snapshots";
        volume.${cfg.rootDirectory}.subvolume = cfg.subvolume;
      };
    };
  };

}
