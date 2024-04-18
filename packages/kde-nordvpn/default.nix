{
  pkgs,
  lib,
  stdenv,
  fetchzip,
}:

let
  pluginName = "plasma-nordvpn";
  pluginId = "com.github.korapp.nordvpn";
in
stdenv.mkDerivation {
  pname = "kde-${pluginName}";
  version = "1.0.1";
  src = fetchzip {
    stripRoot = false;
    url = "https://github.com/korapp/plasma-nordvpn/releases/download/v1.0.1/plasma-nordvpn-1.0.1.plasmoid";
    sha256 = "sha256-JD8uTm1+l2aSniWZ50MQxfrvA50awZX0byeDcbHHrkY=";
    extension = "zip";
  };

  installPhase = ''
    runHook preInstall

    sharePath="$out/share/plasma/plasmoids/${pluginId}"
    mkdir -p $sharePath
    mv * $sharePath

    runHook postInstall
  '';

  meta = with lib; {
    description = "Simple Plasma Applet for the official NordVPN linux client";
    homepage = "https://github.com/korapp/plasma-nordvpn";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
