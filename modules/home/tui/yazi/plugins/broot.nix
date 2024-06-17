{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  name = "broot.yazi";
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

      mkdir -p $out/share/yazi/plugins/${name}
      cp -a $src/* $out/share/yazi/plugins/${name}
      # TODO: cursed chooser.hjson file, should centralize somehow
      sed -i -e 's,@BROOT_CHOOSER_CONFIG@,${../../broot/chooser.hjson},g' $out/share/yazi/plugins/${name}/init.lua

      runHook postInstall
    '';
  };
}
