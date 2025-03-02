{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  name = "hexyl";
in
{
  name = name;

  package = stdenv.mkDerivation {
    pname = name;
    version = "2025-03-02";
    src = fetchFromGitHub {
      owner = "Reledia";
      repo = "hexyl.yazi";
      rev = "228a9ef2c509f43d8da1847463535adc5fd88794";
      hash = "sha256-Xv1rfrwMNNDTgAuFLzpVrxytA2yX/CCexFt5QngaYDg=";
    }; # Patch with the actual binary
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/yazi/plugins/${name}.yazi
      cp -a $src/* $out/share/yazi/plugins/${name}.yazi
      sed -i -e 's,Command("hexyl"),Command("${pkgs.hexyl}/bin/hexyl"),g' $out/share/yazi/plugins/${name}.yazi/main.lua

      runHook postInstall
    '';
  };
}
