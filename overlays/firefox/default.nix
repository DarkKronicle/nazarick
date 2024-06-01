{ pkgs-unstable, ... }:

final: prev:

{ inherit (pkgs-unstable.unstable) firefox-wayland; }
