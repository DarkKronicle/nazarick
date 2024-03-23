{
  config,
  options,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick;
let
  cfg = config.nazarick.suites.impermanence;
in
{
  options.nazarick.suites.impermanence = with types; {
    enable = mkBoolOpt false "Impermanence suite";
  };
  config = mkIf cfg.enable {
    impermanence.enable = true;
    environment.persist = {
      files = [
        "/etc/machine-id"
        "/etc/adjtime"
      ];

      directories = [
        "/var/log"
        "/var/lib/bluetooth"
        "/var/lib/nixos"
        "/var/lib/cups"
        "/var/cache/cups"
        "/var/lib/NetworkManager"
        "/var/lib/sops-nix"
        "/var/lib/systemd"
        "/var/lib/upower"
        "/var/lib/nordvpn"
        "/etc/NetworkManager"
        "/root" # SSH keys + borg stuff, may not be needed anymore
      ];
    };
  };
}
