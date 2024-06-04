# Adapted from https://github.com/name-snrl/nixos-configuration/blob/d67814a85f3d93e5a2f45e6c245f11c692af2a9e/overlays/wallhaven-collection.json
{
  lib,
  pkgs,
  mylib,
  stdenv,
  inputs,
  system,
  wallpapers ? ./wallpapers.yml,
  ...
}:
let
  wallpapers-parsed = ((mylib.importYAML pkgs) wallpapers);
  wallpaperWrapper = import ./wallpaper.nix;
  packageWallpaper =
    wallpaper: (pkgs.callPackage (wallpaperWrapper wallpaper) { inherit inputs system; });
  finalWallpapers = lib.forEach wallpapers-parsed (w: packageWallpaper w);
in
stdenv.mkDerivation {
  pname = "system-wallpapers";
  version = "0.0.1";

  phases = [ "installPhase" ];

  dontUnpack = true;
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/wallpapers
    ${lib.concatStringsSep "\n" (
      lib.forEach finalWallpapers (wpPkg: ''
        ln -s ${wpPkg}/share/wallpapers/* $out/share/wallpapers
      '')
    )}

    runHook postInstall
  '';
}
