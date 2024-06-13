{
  src,
  themes ? [ "none" ],
  svg ? null,
  ...
}:
{
  pkgs,
  lib,
  stdenv,
  inputs,
  fetchurl,
  system,
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
    local filesrc=$src

    ${
      if svg != null then
        (''
          mkdir -p converted
          local filesrc=converted/$(basename $name).png
          ${pkgs.resvg}/bin/resvg ${svg} $src $filesrc
        '')
      else
        ""
    }

    ${
      if plain then
        ''
          cp --reflink=always --no-preserve=mode,ownership $filesrc $out/share/wallpapers
        ''
      else
        ""
    }


    ${lib.concatStringsSep "\n" (
      lib.forEach extra_themes (theme: ''
        ${
          inputs.faerber.packages.${system}.faerber
        }/bin/faerber $filesrc $out/share/wallpapers/${theme}-$name --flavour ${theme}
      '')
    )}

    runHook postBuild
  '';
}
