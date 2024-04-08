{ lib, pkgs }:

pkgs.mpv-unwrapped.override { ffmpeg = pkgs.ffmpeg-full; }
