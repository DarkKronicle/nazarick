{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.nazarick;
let
  username = config.nazarick.user.name;
  cfg = config.nazarick.impermanence;
in
{
  options.nazarick.impermanence = {
    enable = mkEnableOption "Impermanence";
    persist = mkOpt attrs { } "Files and directories to persist in the home";
    transientPersist =
      mkOpt attrs { }
        "Files and directories to persist in the home, but not necessarily backup";
  };

  config = mkIf cfg.enable {
    home.persistence."/persist/keep/home/${username}" = mkAliasDefinitions config.nazarick.persist;
    home.persistence."/persist/transient/home/${username}" = mkAliasDefinitions config.nazarick.transientPersist;
  };
}
