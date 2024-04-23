{
  src,
  themes ? [ "none" ],
  ...
}:
{
  pkgs,
  lib,
  stdenv,
  inputs,
  fetchurl,
  ...
}:
let
  plain = builtins.any (theme: theme == "none") themes;
  extra_themes = builtins.filter (theme: theme != "none") themes;
in
stdenv.mkDerivation {
  pname = "wallpaper-" + src.name;
  version = "1"; # TODO: wth do I put here
  src = fetchurl src;
  dontUnpack = true;
  phases = "buildPhase";

  buildPhase = ''
    runHook preBuild
    mkdir -p $out/share/wallpapers
    local name=$(stripHash $src) 

    ${
      if plain then
        ''
          cp --reflink=always --no-preserve=mode,ownership $src $out/share/wallpapers
        ''
      else
        ""
    }
    ${lib.concatStringsSep "\n" (
      lib.forEach extra_themes (theme: ''
        ${inputs.faerber.packages.x86_64-linux.faerber}/bin/faerber $src $out/share/wallpapers/${theme}-$name --flavour ${theme}
      '')
    )}

    runHook postBuild
  '';
}
