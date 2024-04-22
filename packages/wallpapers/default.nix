# Adapted from https://github.com/name-snrl/nixos-configuration/blob/d67814a85f3d93e5a2f45e6c245f11c692af2a9e/overlays/wallhaven-collection.json
{
  lib,
  pkgs,
  fetchurl,
  stdenv,
  ...
}:
let
  wallpapers = (lib.importJSON ./wallpapers.json);
in
stdenv.mkDerivation {
  pname = "system-wallpapers";
  version = "0.0.1";

  srcs = lib.forEach wallpapers (data: (fetchurl data.src));
  dontUnpack = true;
  sourceRoot = ".";

  # https://discourse.nixos.org/t/cant-copy-more-that-one-file-to-out-in-pkgs-runcommand-permission-denied/11803
  # a issue I had with cp, no-preserve is needed!
  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/wallpapers

    IFS=' '
    for i in $srcs; do
      local tgt="$out/share/wallpapers/$(stripHash $i)"
      cp --reflink=always --no-preserve=mode,ownership $i $tgt
    done

    runHook postInstall
  '';
}
