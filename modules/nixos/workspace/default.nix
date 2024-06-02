{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
{

  imports = mylib.scanPaths ./.;
}
