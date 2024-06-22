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
  };

  config = mkIf cfg.enable {
    sops.secrets."borg/repository" = { };
    sops.secrets."borg/wifi" = { };
    sops.secrets."borg/password" = { };

    services.jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}
