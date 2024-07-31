{
  src,
  themes ? [ "none" ],
  svg ? null,
  square ? false,
  resolution ? null,
  ...
}:
{
  pkgs,
  lib,
  stdenv,
  inputs,
  fetchurl,
  system,
  squareScript,
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

  buildInputs = [
    pkgs.nushell
    pkgs.imagemagick
  ];

  buildPhase = ''
    runHook preBuild
    mkdir -p $out/share/wallpapers
    local name=$(stripHash $src) 
    local oldsrc=$src
    local filesrc=$src

    ${
      if svg != null then
        (''
          mkdir -p converted-svg
          local filesrc=converted-svg/$(basename $name).png
          ${pkgs.resvg}/bin/resvg ${svg} $oldsrc $filesrc
          local oldsrc=$filesrc
        '')
      else
        ""
    }

    ${
      if square then
        (''
          mkdir -p converted-square
          local filesrc=converted-square/$(basename $name).png
          nu ${squareScript}/bin/magick-square $oldsrc $filesrc
          local oldsrc=$filesrc
        '')
      else
        ""
    }

    ${
      if resolution != null then
        (''
          mkdir -p converted-resolution
          local filesrc=converted-resolution/$(basename $name).png
          magick $oldsrc -resize ${resolution} $filesrc
          local oldsrc=$filesrc
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

    nu -c "glob converted-* | each {|folder| if ((\$folder | path type) == "dir") { rm -rp \$folder }}"

    runHook postBuild
  '';
}
