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
    version = "2024-04-23";
    src = fetchFromGitHub {
      owner = "Rolv-Apneseth";
      repo = "starship.yazi";
      rev = "6197e4cca4caed0121654079151632f6abcdcae9";
      hash = "sha256-oHoBq7BESjGeKsaBnDt0TXV78ggGCdYndLpcwwQ8Zts=";
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
