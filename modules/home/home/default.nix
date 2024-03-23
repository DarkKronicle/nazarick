{
  lib,
  osConfig ? { },
  inputs,
  options,
  config,
  ...
}:
with lib;
with lib.nazarick;
{
  # options.home = with types; {
  # persist = mkOpt attrs {} "Files and directories to persist in the home";
  # };

  # home.persistence."/persist/home/darkkronicle" = config.home.persist;

  home.stateVersion = lib.mkDefault (osConfig.system.stateVersion or "23.11");
}
