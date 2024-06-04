{
  lib,
  pkgs,
  config,
  mysecrets,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.nazarick.core.sops;
in
{
  options.nazarick.core.sops = {
    enable = mkEnableOption "Use sops for secrets";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sops
      ssh-to-age
      age
    ];
    sops = {
      defaultSopsFile = "${mysecrets.src}/secrets.yaml";
      age = {
        keyFile = "/persist/system/var/lib/sops-nix/keys.txt";
      };
    };
  };
}
