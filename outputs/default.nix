# Heavily based on:
# https://github.com/ryan4yin/nix-config/blob/82dccbdecaf73835153a6470c1792d397d2881fa/outputs/default.nix
{ self, nixpkgs, ... }@inputs:
let
  # https://github.com/snowfallorg/lib/blob/5d6e9f235735393c28e1145bec919610b172a20f/snowfall-lib/default.nix#L21C1-L33C38
  # Licensed Apache 2.0
  inherit (nixpkgs) lib;

  myvars = import ../vars { inherit lib; };

  mylib = import ../lib { inherit lib; };

  genSpecialArgs =
    system: pkgs_channel: fake_secrets:
    let
      pkgs = import pkgs_channel {
        inherit system;
        config.allowUnfree = true;
      };
    in
    inputs
    // rec {
      inherit
        myvars
        mylib
        system
        inputs
        ;

      mysecrets = import (mylib.relativeToRoot "secrets/create-secrets.nix") {
        inherit
          pkgs
          system
          inputs
          lib
          ;
        fake = fake_secrets;
      };

      # use unstable branch for some packages to get the latest updates
      pkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system; # refer the `system` parameter form outer scope recursively
        config.allowUnfree = true;
      };

      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };

      mypkgs = import (mylib.relativeToRoot "packages") {
        inherit
          pkgs-unstable
          pkgs-stable
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
      myvars
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
}
