{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  name = "broot";
in
{
  name = name;

  package = stdenv.mkDerivation {
    pname = name;
    version = "latest";
    src = ./broot;

    # Patch with the actual binary
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/yazi/plugins/${name}.yazi
      cp -a $src/* $out/share/yazi/plugins/${name}.yazi
      # TODO: cursed chooser.hjson file, should centralize somehow
      sed -i -e 's,@BROOT_CHOOSER_CONFIG@,${../../broot/chooser.hjson},g' $out/share/yazi/plugins/${name}.yazi/init.lua

      runHook postInstall
    '';
  };
}
