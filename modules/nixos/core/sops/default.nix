{
  lib,
  pkgs,
  config,
  mysecrets,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption types;

  cfg = config.nazarick.core.sops;
in
{
  options.nazarick.core.sops = {
    enable = mkEnableOption "Use sops for secrets";
    keyFile = lib.mkOption {
      type = types.str;
      description = "Path for sops file";
      default = "/var/lib/sops-nix/keys.txt";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sops
      ssh-to-age
      age
    ];
    sops = {
      defaultSopsFile = "${mysecrets.src}/secrets.yaml";
      age.keyFile = cfg.keyFile;
    };
  };
}
