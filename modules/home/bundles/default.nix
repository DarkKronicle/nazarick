{ mylib, ... }:
{
  imports = mylib.scanPaths ./.;
}
