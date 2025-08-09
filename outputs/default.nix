# Heavily based on:
# https://github.com/ryan4yin/nix-config/blob/82dccbdecaf73835153a6470c1792d397d2881fa/outputs/default.nix
{ self, nixpkgs, ... }@inputs:
let
  inherit (nixpkgs) lib;

  mylib = import ../lib { inherit lib; };

  # This defines the arguments for each system
  genSpecialArgs =
    {
      system,
      pkgsChannel,
      fakeSecrets,
      variables,
    }:
    let
      pkgs-args = {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      mysecrets = import (mylib.relativeToRoot "secrets/create-secrets.nix") {
        inherit
          pkgs
          system
          inputs
          lib
          ;
        fake = fakeSecrets;
      };

      # Variables specific to the host and whole configuration
      myvars = lib.recursiveUpdate (lib.recursiveUpdate (import ../vars { inherit lib; }) (
        import "${mysecrets.src}/vars.nix"
      )) variables;

      # use unstable branch for some packages to get the latest updates

      pkgs-unstable' = (import inputs.nixpkgs-unstable pkgs-args).applyPatches {
        name = "nixpkgs-unstable-patched";
        src = inputs.nixpkgs-unstable;

        patches = [
          (builtins.fetchurl {
            url = "https://patch-diff.githubusercontent.com/raw/NixOS/nixpkgs/pull/431098.patch";
            sha256 = "sha256-Mz/onCGdLv/bFfMR+Y7nRElrE7Na87jRpWcX9bIqxcU=";
          })
        ];
      };

      pkgs-unstable = import pkgs-unstable' pkgs-args;
      pkgs-unstable-small = import inputs.nixpkgs-unstable-small pkgs-args;

      pkgs-stable = import inputs.nixpkgs-stable pkgs-args;

      # Prevent double initializing package if possible
      pkgs =
        if (pkgsChannel == inputs.nixpkgs-stable) then
          pkgs-stable
        else
          (
            if (pkgsChannel == inputs.nixpkgs-unstable) then pkgs-unstable else (import pkgsChannel pkgs-args)
          );
    in
    inputs
    // rec {
      inherit
        myvars
        mylib
        system
        inputs
        pkgs-stable
        pkgs-unstable
        pkgs-unstable-small
        mysecrets
        ;

      mypkgs = import (mylib.relativeToRoot "packages") {
        inherit
          pkgs-unstable
          pkgs-stable
          pkgs-unstable-small
          system
          inputs
          lib
          myvars
          mylib
          mysecrets
          pkgs
          ;
      };
    };

  args = {
    inherit
      inputs
      lib
      mylib
      genSpecialArgs
      ;
  };

  nixosSystems = {
    x86_64-linux = import ./x86_64-linux (args // { system = "x86_64-linux"; });
  };

  allSystems = nixosSystems;
  allSystemNames = builtins.attrNames allSystems;
  nixosSystemValues = builtins.attrValues nixosSystems;
  allSystemValues = nixosSystemValues;

  # Helper function to generate a set of attributes for each system
  forAllSystems = func: (nixpkgs.lib.genAttrs allSystemNames func);
in
{
  debugAttrs = {
    inherit nixosSystems allSystems allSystemNames;
  };
  nixosConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.nixosConfigurations or { }) nixosSystemValues
  );

  packages = forAllSystems (system: (allSystems.${system}.packages or { }));

  formatter = forAllSystems (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    treefmtEval.config.build.wrapper
  );
}
