{
  lib,
  config,
  myvars,
  ...
}:
let
  cfg = config.nazarick.service.borg;
in
{
  options.nazarick.service.borg = {
    enable = lib.mkEnableOption "borg-serve";

    name = lib.mkOption {
      type = lib.types.str;
      description = "name";
    };

    restrictPath = lib.mkOption {
      type = lib.types.str;
      description = "path for backups";
    };

  };

  config = lib.mkIf cfg.enable {
    services.borgbackup.repos.${cfg.name} = {
      user = "borg";
      group = "borg";
      allowSubRepos = true;
      authorizedKeys = myvars.trusted-keys;
      path = cfg.restrictPath;
    };
  };

}
