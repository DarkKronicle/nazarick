{
  lib,
  stdenv,
  pkgs,
  makeWrapper,
  system,
  inputs,
  ...
}:
let
  requiredPackages =
    (with pkgs; [
      nushell
      ripgrep
      nixfmt-rfc-style
      git
      nix-output-monitor
      nix-prefetch-git
      nh
      nvd
    ])
    ++ [ inputs.lix-module.packages.${system}.default ];
in
stdenv.mkDerivation {
  pname = "naz";
  version = "latest";
  src = ./naz.nu;
  nativeBuildInputs = [ makeWrapper ];
  phases = [ "installPhase" ];
  buildInputs = requiredPackages;
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/naz
    wrapProgram $out/bin/naz --prefix PATH : ${lib.makeBinPath requiredPackages}
  '';
}
