{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.nazarick;
let
  username = "darkkronicle";
  cfg = config.nazarick.impermanence;
in
{
  options.nazarick.impermanence = with types; {
    enable = mkEnableOption "Impermanence";
    persist = mkOpt attrs { } "Files and directories to persist in the home";
    transientPersist =
      mkOpt attrs { }
        "Files and directories to persist in the home, but not necessarily backup";
  };

  config = mkIf cfg.enable {
    nazarick.impermanence.persist.allowOther = mkDefault true;
    nazarick.impermanence.transientPersist.allowOther = mkDefault true;
    home.persistence."/persist/keep/home/${username}" = cfg.persist;
    home.persistence."/persist/transient/home/${username}" = cfg.transientPersist;
  };
}
