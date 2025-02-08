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
    version = "2025-01-03";
    src = fetchFromGitHub {
      owner = "Reledia";
      repo = "hexyl.yazi";
      rev = "39d3d4e23ad7cec8888f648ddf55af4386950ce7";
      hash = "sha256-nsnnL3GluKk/p1dQZTZ/RwQPlAmTBu9mQzHz1g7K0Ww=";
    };
    # Patch with the actual binary
    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/yazi/plugins/${name}.yazi
      cp -a $src/* $out/share/yazi/plugins/${name}.yazi
      sed -i -e 's,Command("hexyl"),Command("${pkgs.hexyl}/bin/hexyl"),g' $out/share/yazi/plugins/${name}.yazi/init.lua
      sed -i -e 's,self.file.cha.len,job.file.cha.len,g' $out/share/yazi/plugins/${name}.yazi/init.lua

      runHook postInstall
    '';
  };
}
