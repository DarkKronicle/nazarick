{
  inputs,
  lib,
  mylib,
  system,
  genSpecialArgs,
  fake-secrets ? true,
  nixpkgs ? (inputs.nixpkgs),
  specialArgs ? (
    genSpecialArgs {
      inherit system;
      pkgsChannel = nixpkgs;
      fakeSecrets = fake-secrets;
    }
  ),
  nix-modules ? [ ],
  home-modules ? [ ],
  home-root ? null,
  home-manager ? inputs.home-manager,
  ...
}:
let
  inherit (inputs) nixos-generators;
  overlays = import (mylib.relativeToRoot "overlays") {
    inherit
      inputs
      lib
      mylib
      system
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
    (
      { config, ... }:
      {
        config = {
          # Global home manager settings
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = specialArgs;
          home-manager.backupFileExtension = "backup";

          home-manager.users = lib.mkMerge (
            (mylib.forEachUserAttr config) (
              user: cfg: {
                ${user} = {
                  imports = home-modules ++ [ "${home-root}/${cfg.homeManagerFileName}" ];
                  # nixpkgs.overlays = overlays; # TODO: I don't think this is needed, but should probably double check
                };
              }
            )
          );
        };
      }
    )
    {
      assertions = [
        {
          assertion = specialArgs.mysecrets.valid;
          message = specialArgs.mysecrets.message;
        }
      ];
    }
  ];
}
