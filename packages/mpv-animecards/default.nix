{
  pkgs,
  inputs,
  lib,
  mysecrets,
  runCommand,
}:

# Source for this is found on https://animecards.site/minefromanime/
# I could not find any mention of a license, and since the file is hosted
# on mega.nz I couldn't think of a good way to package it.
# So I put it on my private repo to not have to distribute it and
# so I wouldn't be violating someone's copyright.
# Maybe in the future I'll write my own from scratch.

# TODO: Looking into this slightly more it looks I can add the megacmd as a build input
# and then fetch from there.
# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/build-support/fetchurl/default.nix#L148

let
  file = builtins.toPath "${mysecrets.src}/packages/animecards.lua";
in
pkgs.mpvScripts.buildLua {
  pname = "mpv-animecards";
  version = "1.0.0";

  src = file;

  # Unpack just needs to put it in the correct spot :)
  unpackPhase = ''
    cp $src animecards.lua
  '';

  # Weird issue rn. libwebp stopped working when this was packaged differently. Need to take a look into this.
  passthru.extraWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    "${lib.getBin pkgs.mpv-unwrapped}/bin"
  ];

  meta = {
    description = "mpv script for animecards";
    homepage = "https://animecards.site/minefromanime/";
    license = lib.licenses.unfree;
  };
}
