{
  lib,
  osConfig ? {},
  ...
}: {
  home.stateVersion = lib.mkDefault (osConfig.system.stateVersion or "23.11");
}
