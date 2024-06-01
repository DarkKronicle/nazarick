{
  inputs,
  lib,
  mylib,
  myvars,
  system,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
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
          myvars
          system
          pkgs
          pkgs-stable
          pkgs-unstable
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
