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
  home.stateVersion = lib.mkDefault (osConfig.system.stateVersion or "23.11");
}
