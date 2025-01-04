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
    version = "2025-01-03";
    src = fetchFromGitHub {
      owner = "Sonico98";
      repo = "exifaudio.yazi";
      rev = "d7946141c87a23dcc6fb3b2730a287faf3154593";
      hash = "sha256-nXBxPG6PVi5vstvVMn8dtnelfCa329CTIOCdXruOxT4=";
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
