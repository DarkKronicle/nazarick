# Adapted from https://github.com/name-snrl/nixos-configuration/blob/d67814a85f3d93e5a2f45e6c245f11c692af2a9e/overlays/wallhaven-collection.json
{
  lib,
  pkgs,
  fetchurl,
  stdenv,
  inputs,
  ...
}:
let
  wallpapers = ((lib.nazarick.importYAML pkgs) ./wallpapers.yml);
in
stdenv.mkDerivation {
  pname = "system-wallpapers";
  version = "0.0.1";

  srcs = lib.forEach wallpapers (data: (fetchurl data.src));
  dontUnpack = true;
  sourceRoot = ".";

  buildPhase = ''
    runHook preBuild

    ${pkgs.nushell}/bin/nu ${./build_wallpapers.nu} ${inputs.faerber.packages.x86_64-linux.faerber}/bin/faerber $out ${./wallpapers.yml} $srcs

    runHook postBuild
  '';
}
