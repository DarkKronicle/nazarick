{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  name = "ouch.yazi";
in
{
  name = name;

  package = stdenv.mkDerivation {
    pname = name;
    version = "2024-04-23";
    src = fetchFromGitHub {
      owner = "ndtoan96";
      repo = "ouch.yazi";
      rev = "694d149be5f96eaa0af68d677c17d11d2017c976";
      hash = "sha256-J3vR9q4xHjJt56nlfd+c8FrmMVvLO78GiwSNcLkM4OU=";
    };

    # Patch with the actual binary
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/yazi/plugins/${name}
      cp -a $src/* $out/share/yazi/plugins/${name}
      sed -i -e 's,Command("ouch"),Command("${pkgs.ouch}/bin/ouch"),g' $out/share/yazi/plugins/${name}/init.lua

      runHook postInstall
    '';
  };
}
