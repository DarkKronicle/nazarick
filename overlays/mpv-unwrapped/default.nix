# This is extra needed because some scripts require the mpv binary, and without
# specifying an overlay, it could use one without this ffmpeg version.
{ channels, ... }:

final: prev:

{ mpv-unwrapped = prev.mpv-unwrapped.override { ffmpeg = prev.ffmpeg-full; }; }
