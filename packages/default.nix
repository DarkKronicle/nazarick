{
  inputs,
  lib,
  mylib,
  system,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  mysecrets,
  ...
}:
lib.listToAttrs (
  lib.forEach (mylib.scanPaths ./.) (
    package:
    let
      extra-inputs = {
        inherit
          inputs
          lib
          system
          pkgs
          pkgs-stable
          pkgs-unstable
          mysecrets
          mylib
          ;
      };
      pkg = (lib.callPackageWith (pkgs // extra-inputs) package { });
    in
    {
      name = if (builtins.hasAttr "pname" pkg) then pkg.pname else pkg.name;
      value = pkg;
    }
  )
)
