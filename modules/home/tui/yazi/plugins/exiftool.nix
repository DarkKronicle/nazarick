{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  name = "exifaudio";
in
{
  name = name;

  package = stdenv.mkDerivation {
    pname = name;
    version = "2025-03-02";
    src = fetchFromGitHub {
      owner = "Sonico98";
      repo = "exifaudio.yazi";
      rev = "4379fcfa2dbe0b81fde2dd67b9ac2e0e48331419";
      hash = "sha256-CIimJU4KaKyaKBuiBvcRJUJqTG8pkGyytT6bPf/x8j8=";
    }; # Patch with the actual binary
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/yazi/plugins/${name}.yazi
      cp -a $src/* $out/share/yazi/plugins/${name}.yazi
      sed -i -e 's,Command("exiftool"),Command("${pkgs.exiftool}/bin/exiftool"),g' $out/share/yazi/plugins/${name}.yazi/main.lua

      runHook postInstall
    '';
  };
}
