{
  pkgs,
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:
let
  name = "starship.yazi";
in
{
  name = name;
  init_lua_text = ''require("starship"):setup()'';

  package = stdenv.mkDerivation {
    pname = name;
    version = "2025-01-03";
    src = fetchFromGitHub {
      owner = "Rolv-Apneseth";
      repo = "starship.yazi";
      rev = "9c37d37099455a44343f4b491d56debf97435a0e";
      hash = "sha256-wESy7lFWan/jTYgtKGQ3lfK69SnDZ+kDx4K1NfY4xf4=";
    };
    # Patch with the actual binary
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/yazi/plugins/${name}
      cp -a $src/* $out/share/yazi/plugins/${name}
      sed -i -e 's,Command("starship"),Command("${pkgs.starship}/bin/starship"),g' $out/share/yazi/plugins/${name}/init.lua

      runHook postInstall
    '';
  };
}
