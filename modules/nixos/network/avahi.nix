{
  mylib,
  lib,
  config,
  myvars,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.nazarick.network.avahi;
in
{

  options.nazarick.network.avahi = {
    enable = mkOption {
      type = types.bool;
      description = "Avahi local discovery";
      default = true;
    };

    publish = mkOption {
      type = types.bool;
      description = "Allow publishing to local network";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # https://github.com/ryan4yin/nix-config/blob/main/modules/nixos/base/networking.nix
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      publish = {
        enable = true;
        domain = true;
        userServices = true;
      };
    };
  };
}
