{ pkgs, lib, ... }:

pkgs.stdenvNoCC.mkDerivation {
  name = "operator-caska";

  src = pkgs.fetchFromGitHub {
      owner = "Anant-mishra1729";
      repo = "Operator-caska-Font";
      rev = "b4c0e56b762ef6e602e858773b30889726b3b9b6";

      sha256 = "LUAyKt4ksyDLxmennmvWAREE+D8qKzVOUw6srOFmhGA=";

  };

  installPhase = ''
    mkdir -p $out/share/fonts/truetype/
    cp -R *.ttf $out/share/fonts/truetype/
  '';
  meta = { description = "Cascadia Code patched with Operator Mono"; };

}
