{
  options,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.nazarick.system.memory;
in
{
  options.nazarick.system.memory = {
    enable = mkEnableOption "Enable better memory management";
  };
  config = mkIf cfg.enable {
    services.earlyoom = {
      enable = true;
      # https://discourse.nixos.org/t/nix-build-ate-my-ram/35752/5
      extraArgs =
        let
          catPatterns = patterns: builtins.concatStringsSep "|" patterns;
          preferPatterns = [
            ".firefox-wrappe"
            ".nheko-wrapped"
            "java"
          ];
          avoidPatterns = [
            ".kitty-wrapped"
            "sshd"
            "systemd"
            "systemd-logind"
            "systemd-udevd"
            ".plasmashell-wr"
          ];
        in
        [
          "--prefer '^(${catPatterns preferPatterns})$'"
          "--avoid '^(${catPatterns avoidPatterns})$'"
        ];
    };
  };
}
