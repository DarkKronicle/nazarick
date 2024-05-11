{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;

  cfg = config.nazarick.system.sops;
in
{
  options.nazarick.system.sops = {
    enable = mkEnableOption "Use sops for secrets";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      sops
      ssh-to-age
      age
    ];
    sops = {
      defaultSopsFile = "${builtins.toString inputs.mysecrets}/secrets.yaml";
      age = {
        keyFile = "/persist/system/var/lib/sops-nix/keys.txt";
      };
    };
  };
}
