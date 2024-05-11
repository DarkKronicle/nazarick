{
  pkgs,
  lib,
  stdenv,
  fetchzip,
}:

let
  pluginName = "application-title-bar";
  pluginId = "com.github.antroids.application-title-bar";
in
stdenv.mkDerivation {
  pname = "kde-${pluginName}";
  version = "0.5.0";
  src = fetchzip {
    stripRoot = false;
    url = "https://github.com/antroids/application-title-bar/releases/download/v0.5.0/application-title-bar.plasmoid";
    sha256 = "sha256-pSdffNVZA2M7tlp1tFkBmCVgY7qZRDKB9iDGgqXh4tQ=";
    extension = "zip";
  };

  installPhase = ''
    runHook preInstall

    sharePath="$out/share/plasma/plasmoids/${pluginId}"
    mkdir -p $sharePath
    mv * $sharePath

    runHook postInstall
  '';

  meta = {
    description = "Application title bar for Plasma with controls";
    homepage = "https://github.com/antroids/application-title-bar";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.linux;
  };
}
