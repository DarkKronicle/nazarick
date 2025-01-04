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
    version = "2025-01-03";
    src = fetchFromGitHub {
      owner = "ndtoan96";
      repo = "ouch.yazi";
      rev = "b8698865a0b1c7c1b65b91bcadf18441498768e6";
      hash = "sha256-eRjdcBJY5RHbbggnMHkcIXUF8Sj2nhD/o7+K3vD3hHY=";
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
