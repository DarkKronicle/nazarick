{ channels, ... }:

final: prev:

{ mpv-unwrapped = prev.mpv-unwrapped.override { ffmpeg = prev.ffmpeg-full; }; }
