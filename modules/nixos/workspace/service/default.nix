{ mylib, ... }:
{

  imports = mylib.scanPaths ./.;
}