{
  inputs,
  lib,
  mylib,
  mypkgs,
  system,
  pkgs,
  pkgs-stable,
  pkgs-unstable,
  pkgs-unstable-small,
  ...
}:
lib.forEach (mylib.scanPaths ./.) (
  overlay:
  import overlay {
    inherit
      inputs
      lib
      mypkgs
      system
      pkgs
      pkgs-stable
      pkgs-unstable
      pkgs-unstable-small
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
