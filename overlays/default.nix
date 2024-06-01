{
  inputs,
  lib,
  myvars,
  mylib,
  mypkgs,
  system,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  ...
}:
lib.forEach (mylib.scanPaths ./.) (
  overlay:
  import overlay {
    inherit
      inputs
      lib
      mypkgs
      myvars
      system
      pkgs
      pkgs-stable
      pkgs-unstable
      ;
  }
)
++ [
  (
    final: prev:
    let
      pkgs = inputs.fenix.inputs.nixpkgs.legacyPackages.${prev.system};
    in
    inputs.fenix.overlays.default pkgs pkgs
  )
  inputs.nix-matlab.overlay
]
