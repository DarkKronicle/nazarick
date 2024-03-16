{
  pkgs,
  fetchurl,
  fetchzip,
  lib,
  stdenv,
  autoPatchelfHook,
  glibc,
  libgcc,
  xorg,
  harfbuzz,
  freetype,
  libjpeg8,
  giflib,
  alsa-lib,
  lcms,
}:
let
  pname = "kamite-bin";
  version = "0.13";
in
stdenv.mkDerivation {
  inherit pname version;
  src = fetchzip {
    url = "https://github.com/fauu/Kamite/releases/download/v${version}/Kamite_${version}_Linux.zip";
    hash = "sha256-ukJY25CKnMdJshtlh/uwEmhHhUmEOt1Vna0rGvkUqOc=";
  };

  system = "x86_64-linux";

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libgcc
    libgcc.lib
    glibc
    xorg.libXext
    xorg.libX11
    xorg.libXrender
    xorg.libXtst
    xorg.libXi
    harfbuzz
    freetype
    libjpeg8
    giflib
    alsa-lib
    lcms
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv bin/kamite $out/bin
    mv lib $out/lib
    mv runtime $out/runtime

    runHook postInstall
  '';

  meta = {
    description = "Japanese Learning Utility";
    homepage = "https://github.com/fauu/Kamite";
    platforms = [ "x86_64-linux" ];
  };
}
