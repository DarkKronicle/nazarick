# This is extra needed because some scripts require the mpv binary, and without
# specifying an overlay, it could use one without this ffmpeg version.
{ channels, ... }:

final: prev:

{
  steam = prev.steam.override {
    extraPkgs =
      pkgs: with pkgs; [
        xorg.libXcursor
        xorg.libXi
        xorg.libXinerama
        xorg.libXScrnSaver
        libpng
        libpulseaudio
        libvorbis
        stdenv.cc.cc.lib
        libkrb5
        keyutils
      ];
  };
}
