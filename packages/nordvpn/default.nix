# https://github.com/nix-community/nur-combined/blob/master/repos/LuisChDev/pkgs/nordvpn/default.nix#L88
# This was just slightly updated. Works well, just make sure to set user gruops properly
{
  autoPatchelfHook,
  buildFHSEnvChroot ? false,
  buildFHSEnv ? false,
  dpkg,
  fetchurl,
  lib,
  stdenv,
  sysctl,
  iptables,
  iproute2,
  procps,
  cacert,
  libxml2,
  libidn2,
  libnl,
  libcap_ng,
  zlib,
  wireguard-tools,
}:

let
  pname = "nordvpn";
  version = "3.20.0";
  buildEnv = if builtins.typeOf buildFHSEnvChroot == "set" then buildFHSEnvChroot else buildFHSEnv;

  nordVPNBase = stdenv.mkDerivation {
    inherit pname version;

    src = fetchurl {
      url = "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/n/nordvpn/nordvpn_${version}_amd64.deb";
      hash = "sha256-3/HSCTPt/1CprrpVD60Ga02Nz+vBwNBE1LEl+7z7ADs=";
    };

    buildInputs = [
      libxml2
      libidn2
      libnl
      libcap_ng
    ];
    nativeBuildInputs = [
      dpkg
      autoPatchelfHook
      stdenv.cc.cc.lib
    ];

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      runHook preUnpack
      dpkg --extract $src .
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      mv usr/* $out/
      mv var/ $out/
      mv etc/ $out/
      runHook postInstall
    '';
  };

  nordVPNfhs = buildEnv {
    name = "nordvpnd";
    runScript = "nordvpnd";

    # hardcoded path to /sbin/ip
    targetPkgs =
      pkgs: with pkgs; [
        nordVPNBase
        sysctl
        iptables
        iproute2
        procps
        cacert
        libxml2
        libidn2
        zlib
        wireguard-tools
      ];
  };
in
stdenv.mkDerivation {
  inherit pname version;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/share
    ln -s ${nordVPNBase}/bin/nordvpn $out/bin
    ln -s ${nordVPNfhs}/bin/nordvpnd $out/bin
    ln -s ${nordVPNBase}/share* $out/share
    ln -s ${nordVPNBase}/var $out/
    runHook postInstall
  '';

  meta = {
    description = "CLI client for NordVPN";
    homepage = "https://www.nordvpn.com";
    license = lib.licenses.unfree;
    platforms = [ "x86_64-linux" ];
  };
}
