{
  lib,
  pkgs,
  mylib,
  config,
  inputs,
  mysecrets,
  ...
}:
let
  inherit (mylib) enabled;
in
{
  nazarick.cli.starship.hostnameColor = "#274ab0";
}
