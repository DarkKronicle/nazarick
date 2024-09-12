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
}@args:
let

  mainPackages = lib.listToAttrs (
    lib.forEach (builtins.filter (path: !(lib.strings.hasInfix "scripts" path)) (mylib.scanPaths ./.)) (
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
  );

  scripts = import ./scripts (
    {
      inherit
        inputs
        lib
        system
        pkgs
        pkgs-stable
        pkgs-unstable
        mysecrets
        ;
    }
    // args
  );
in
mainPackages // scripts
