{ lib, pkgs }:

# This may be better as an overlay, but I do like the central location /shrug
pkgs.mpv-unwrapped.override { ffmpeg = pkgs.ffmpeg-full; }
