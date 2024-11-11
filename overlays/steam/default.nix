{ ... }:

final: prev:

{
  steam = prev.steam.override {
    # Fix for: https://github.com/NixOS/nixpkgs/issues/353405
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
