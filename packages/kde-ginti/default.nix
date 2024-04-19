{
  pkgs,
  lib,
  stdenv,
}:

let
  pluginName = "ginti";
in
stdenv.mkDerivation {
  pname = "kde-${pluginName}";
  version = "0.3";
  src = fetchTarball {
    url = "https://github.com/dhruv8sh/plasma6-desktopindicator-gnome/archive/refs/tags/v0.3.tar.gz";
    sha256 = "sha256:1d2az907c3y48b0ydxhwz4isr3xn9hl5qp8ii1s76l8ld9hkpny0";
  };

  # Without this plasma can't properly find the format
  patches = [ ./metadata.patch ];

  installPhase = ''
    runHook preInstall

    sharePath="$out/share/plasma/plasmoids/org.kde.plasma.${pluginName}"
    mkdir -p $sharePath
    mv * $sharePath

    runHook postInstall
  '';

  meta = with lib; {
    description = " Plasma 6 applet in order to show virtual desktops in a minimal way, Gnome style";
    homepage = "https://github.com/dhruv8sh/plasma6-desktopindicator-gnome";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
