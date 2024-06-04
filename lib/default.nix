{ lib, ... }:

{
  # https://github.com/ryan4yin/nix-config/blob/82dccbdecaf73835153a6470c1792d397d2881fa/lib/default.nix#L13
  # use path relative to the root of the project
  relativeToRoot = lib.path.append ../.;
  scanPaths =
    path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
          (_type == "directory") # include directories
          || (
            (path != "default.nix") # ignore default.nix
            && (lib.strings.hasSuffix ".nix" path) # include .nix files
          )
        ) (builtins.readDir path)
      )
    );

  nixosSystem =
    {
      inputs,
      lib,
      mylib,
      system,
      genSpecialArgs,
      myvars,
      fake-secrets ? true,
      nixpkgs ? (inputs.nixpkgs),
      specialArgs ? (genSpecialArgs system nixpkgs fake-secrets),
      nix-modules ? [ ],
      home-modules ? [ ],
      ...
    }:
    let
      inherit (inputs) home-manager nixos-generators;
      overlays = import (mylib.relativeToRoot "overlays") {
        inherit
          inputs
          lib
          mylib
          system
          myvars
          ;
        inherit (specialArgs) pkgs-stable pkgs-unstable mypkgs;
        pkgs = nixpkgs;
      };
    in
    nixpkgs.lib.nixosSystem {
      inherit system specialArgs;
      modules = nix-modules ++ [
        nixos-generators.nixosModules.all-formats
        home-manager.nixosModules.home-manager
        {
          # NixOS overlays
          nixpkgs.overlays = overlays;
        }
        {
          home-manager.users."${myvars.username}".imports = home-modules;
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          # Home manager overlays
          nixpkgs.overlays = overlays;
        }
        {
          assertions = [
            {
              assertion = specialArgs.mysecrets.valid;
              message = specialArgs.mysecrets.message;
            }
          ];
        }
      ];
    };
}
// (import ./module { inherit lib; })
// (import ./package { inherit lib; })
// (import ./package/mkwindowsapp { inherit lib; })
