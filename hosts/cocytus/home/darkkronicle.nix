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
  nazarick.cli.starship.hostnameColor = "#06194f";
}
