{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  name = "exifaudio.yazi";
in
{
  name = name;

  package = stdenv.mkDerivation {
    pname = name;
    version = "2024-04-23";
    src = fetchFromGitHub {
      owner = "Sonico98";
      repo = "exifaudio.yazi";
      rev = "94329ead8b3a6d3faa2d4975930a3d0378980c7a";
      hash = "sha256-jz6fVtcLHw9lsxFWECbuxE7tEBttE08Fl4oJSTifaEc=";
    }; # Patch with the actual binary
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/yazi/plugins/${name}
      cp -a $src/* $out/share/yazi/plugins/${name}
      sed -i -e 's,Command("exiftool"),Command("${pkgs.exiftool}/bin/exiftool"),g' $out/share/yazi/plugins/${name}/init.lua

      runHook postInstall
    '';
  };
}
