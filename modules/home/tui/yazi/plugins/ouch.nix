{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  name = "ouch";
in
{
  name = name;

  package = stdenv.mkDerivation {
    pname = name;
    version = "2025-03-02";
    src = fetchFromGitHub {
      owner = "ndtoan96";
      repo = "ouch.yazi";
      rev = "ce6fb75431b9d0d88efc6ae92e8a8ebb9bc1864a";
      hash = "sha256-oUEUGgeVbljQICB43v9DeEM3XWMAKt3Ll11IcLCS/PA=";
    };

    # Patch with the actual binary
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/yazi/plugins/${name}.yazi
      cp -a $src/* $out/share/yazi/plugins/${name}.yazi
      sed -i -e 's,Command("ouch"),Command("${pkgs.ouch}/bin/ouch"),g' $out/share/yazi/plugins/${name}.yazi/main.lua

      runHook postInstall
    '';
  };
}
