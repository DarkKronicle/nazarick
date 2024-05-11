{
  pkgs,
  lib,
  inputs,
  fetchurl,
  copyDesktopItems,
  makeDesktopItem,
  wine,
  stdenv,
  writeShellScript,
  winetricks,
  gnused,
  fuse-overlayfs,
  ...
}:

let
  mkWindowsApp = lib.nazarick.mkwindowsapp {
    inherit
      stdenv
      gnused
      fuse-overlayfs
      writeShellScript
      winetricks
      ;
    makeBinPath = pkgs.lib.makeBinPath;
    cabextract = pkgs.cabextract;
  };
in
mkWindowsApp rec {
  inherit wine;
  name = "ltspice";
  src = fetchurl {
    url = "https://ltspice.analog.com/software/LTspice64.msi";
    sha256 = "sha256-U1ZFb9JhgJ7g9/zaYOCtOWlXqz//kQCkNRlNcxQ9d+g=";
  };

  wineArch = "win64";

  nativeBuildInputs = [ copyDesktopItems ];
  dontUnpack = true;

  winAppInstall = ''
    echo ${src}
    wine start /unix ${src} /S
  '';

  winAppRun = ''
    wine start /unix "$WINEPREFIX/drive_c/Program Files/LTSpice/LTspice.exe" "$ARGS"
  '';

  installPhase = ''
    runHook preInstall

    ln -s $out/bin/.launcher $out/bin/ltspice

    runHook postInstall
  '';

  desktopItems = makeDesktopItem {
    name = "LTSpice";
    exec = "ltspice";
    desktopName = "LTSpice";
    categories = [ "Utility" ];
  };

  meta = {
    description = "Circuit simulator";
    platforms = [
      "x86_64-linux"
      "i386-linux"
    ];
  };
}
