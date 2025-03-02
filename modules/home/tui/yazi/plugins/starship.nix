{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  name = "starship";
in
{
  name = name;
  init_lua_text = ''require("starship"):setup()'';

  package = stdenv.mkDerivation {
    pname = name;
    version = "2025-03-02";
    src = fetchFromGitHub {
      owner = "Rolv-Apneseth";
      repo = "starship.yazi";
      rev = "6c639b474aabb17f5fecce18a4c97bf90b016512";
      hash = "sha256-bhLUziCDnF4QDCyysRn7Az35RAy8ibZIVUzoPgyEO1A=";
    }; # Patch with the actual binary
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/yazi/plugins/${name}.yazi
      cp -a $src/* $out/share/yazi/plugins/${name}.yazi
      sed -i -e 's,Command("starship"),Command("${pkgs.starship}/bin/starship"),g' $out/share/yazi/plugins/${name}.yazi/main.lua

      runHook postInstall
    '';
  };
}
