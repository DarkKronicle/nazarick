{ lib, ... }:
rec {
  mkCA =
    pkgs:
    pkgs.runCommand "mkcert-CA" { } ''
      mkdir -p $out/certs
      HOME=$TMPDIR
      CAROOT=$out
      ${pkgs.mkcert}/bin/mkcert tmp.local
      mv $HOME/.local/share/mkcert/* $out/
    '';

  mkLocalCert =
    pkgs: domains: name:
    pkgs.runCommand "mkcert-${domains}" { } ''
      mkdir -p $out
      HOME=$TMPDIR
      mkdir -p $HOME/.local/share/mkcert/
      cp ${mkCA pkgs}/root* $HOME/.local/share/mkcert/
      CAROOT=${mkCA pkgs}
      cd $out
      ${pkgs.mkcert}/bin/mkcert -cert-file=${name}.pem -key-file=${name}-key.pem ${domains}
    '';
}
