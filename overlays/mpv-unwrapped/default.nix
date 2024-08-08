# This is extra needed because some scripts require the mpv binary, and without
# specifying an overlay, it could use one without this ffmpeg version.
{ pkgs-unstable, ... }:

final: prev:

{
  mpv-unwrapped = pkgs-unstable.mpv-unwrapped.override { ffmpeg = prev.ffmpeg-full; };
  mpv-unwrapped-normal = prev.mpv-unwrapped;
}
