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
  cfg = config.nazarick.home.suites.impermanence;
in
{
  options.nazarick.home.suites.impermanence = with types; {
    enable = mkBoolOpt false "Impermanence suite";
  };
  config = mkIf cfg.enable {
    nazarick.impermanence.enable = true;
    nazarick.impermanence.persist = {
      hideMounts = true;
      files = [ ];

      directories = [
        ".config/nvim"
        ".config/filezilla"
        ".config/drg_mod_integration"
        ".config/matlab"
        ".config/mpv"
        ".config/qalculate"
        ".config/easyeffects"
        ".local/share/atuin"
        ".borg"
        "Documents"
      ];
    };
    nazarick.impermanence.transientPersist = {
      hideMounts = true;
      files = [

      ];

      directories = [
        ".config/nordvpn"
        ".config/borg"
        ".config/kdeconnect"
        ".config/vesktop"
        ".config/Mumble"
        ".config/nheko"
        ".config/nixpkgs"
        ".mozilla"
        ".applications/matlab"
        "Downloads"
      ];
    };
  };
}
