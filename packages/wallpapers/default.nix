# Adapted from https://github.com/name-snrl/nixos-configuration/blob/d67814a85f3d93e5a2f45e6c245f11c692af2a9e/overlays/wallhaven-collection.json
{
  lib,
  pkgs,
  mylib,
  stdenv,
  inputs,
  system,
  filterFunc ? (wall: true),
  wallpapers ? ./wallpapers.yml,
  name ? "system-wallpapers",
  ...
}:
let
  squareScript =
    mylib.writeScript pkgs "magick-square" # nu
      ''
          #!/usr/bin/env nu
          
          def main [input: path, output: path] {
            let dimensions = magick identify $input | split row " " | get 2 | split row "x" | into int
            let smallest = $dimensions | math min
            let largest = $dimensions | math max
            if ($smallest == $largest) {
                # Already square
                cp $input $output
                return
            }
            # true if smallest is width
            let width_wise = ($smallest == ($dimensions | get 0))
            let offset = ($largest - $smallest) / 2 | math ceil
            let hoffset = if $width_wise {
                0
            } else {
                $offset
            }
            let voffset = if $width_wise {
                $offset
            } else {
                0
            }
            let dimensions = $"($smallest)x($smallest)+($hoffset)+($voffset)"
            magick $input -crop $dimensions $output
        }
      '';

  wallpapers-parsed = ((mylib.importYAML pkgs) wallpapers);
  wallpaperWrapper = import ./wallpaper.nix;
  packageWallpaper =
    wallpaper:
    (pkgs.callPackage (wallpaperWrapper wallpaper) {
      inherit
        inputs
        system
        squareScript
        ;
    });
  finalWallpapers = lib.forEach (builtins.filter filterFunc wallpapers-parsed) (
    w: packageWallpaper w
  );
in
stdenv.mkDerivation {
  pname = name;
  version = "0.0.1";

  phases = [ "installPhase" ];

  dontUnpack = true;
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/wallpapers/${name}
    mkdir -p $out/gc
    ${lib.concatStringsSep "\n" (
      lib.forEach finalWallpapers (wpPkg: ''
        ln -s ${wpPkg}/share/wallpapers/* $out/share/wallpapers/${name}
        ln -s ${wpPkg}/gc/* $out/gc
      '')
    )}

    runHook postInstall
  '';
}
