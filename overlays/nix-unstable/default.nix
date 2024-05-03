# This is extra needed because some scripts require the mpv binary, and without
# specifying an overlay, it could use one without this ffmpeg version.
{ channels, ... }:

final: prev:

{
  # This is another one of those issues that targets me like 12 levels deep
  # This could have been fixed in 3 places, but I guess that's what happens with such a massive project.

  # https://github.com/NixOS/nixpkgs/blob/dd44f4056dbc8033a1490a08b090244ac221be84/pkgs/top-level/aliases.nix#L868
  # https://github.com/snowfallorg/lib/blob/92803a029b5314d4436a8d9311d8707b71d9f0b6/modules/nixos/user/default.nix#L85
  # https://github.com/gytis-ivaskevicius/flake-utils-plus/blob/bfc53579db89de750b25b0c5e7af299e0c06d7d3/lib/mkFlake.nix#L170
  # https://github.com/NixOS/nixpkgs/pull/305951

  nixUnstable = prev.nixVersions.git;
}
