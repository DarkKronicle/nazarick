{
  pkgs,
  lib,
  stdenv,
  fetchzip,
}:

let
  pluginName = "citygrow";
  pluginId = "org.kde.plasma.citygrow";
in
stdenv.mkDerivation {
  pname = "kde-${pluginName}";
  version = "1.1.0";
  src = fetchzip {
    stripRoot = false;
    url = "https://github.com/HobbyBlobby/PlasmaWallpaper_CityGrow/raw/main/package/PlasmaWallpaper6_CityGrow_1-3.zip";
    sha256 = "sha256-pV4C2RCW+6X2znhTa9EzkwxK8RDhgecB1jSbCMxyhTo=";
    extension = "zip";
  };

  installPhase = ''
    runHook preInstall

    sharePath="$out/share/plasma/wallpapers/${pluginId}"
    mkdir -p $sharePath
    mv * $sharePath

    runHook postInstall
  '';

  meta = {
    description = "Plasma Wallpaper Plugin (also Screen Lock) with growing city animation";
    homepage = "https://github.com/HobbyBlobby/PlasmaWallpaper_CityGrow";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
