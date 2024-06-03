{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  name = "hexyl.yazi";
in
{
  name = name;

  package = stdenv.mkDerivation {
    pname = name;
    version = "2024-04-23";
    src = fetchFromGitHub {
      owner = "Reledia";
      repo = "hexyl.yazi";
      rev = "1c6007c96af97704b4ebb877a8385fc034f8b44a";
      hash = "sha256-/quz3xaCS0NxOdnGLz1wutbDiXp2Yr2TRAZF9XVJzdk=";
    };
    # Patch with the actual binary
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/yazi/plugins/${name}
      cp -a $src/* $out/share/yazi/plugins/${name}
      sed -i -e 's,Command("hexyl"),Command("${pkgs.hexyl}/bin/hexyl"),g' $out/share/yazi/plugins/${name}/init.lua

      runHook postInstall
    '';
  };
}
