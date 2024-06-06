{ stdenv, dnscrypt-proxy2, ... }:
stdenv.mkDerivation {
  pname = "generate-domains-blocklist";
  version = "0059194a-patch";

  dontUnpack = true;
  src = dnscrypt-proxy2.src;

  buildPhase = ''
    mkdir -p $out/
    patch $src/utils/generate-domains-blocklist/generate-domains-blocklist.py -o $out/generate-domains-blocklist.py < ${./no-trusted.patch}
  '';
}
