{
  # NOTE: the args not used in this file CAN NOT be removed!
  # because haumea pass argument lazily,
  inputs,
  lib,
  mylib,
  system,
  genSpecialArgs,
  ...
}@args:
let
  name = "cocytus";
  modules = {
    nix-modules = [
      {
        home-manager.sharedModules = [
          inputs.nix-index-database.hmModules.nix-index
          inputs.sops-nix.homeManagerModules.sops
          inputs.firefox-arkenfox.hmModules.arkenfox
          inputs.nix-flatpak.homeManagerModules.nix-flatpak
        ];
      }
    ]
    ++ (with inputs; [
      impermanence.nixosModules.impermanence
      home-manager-stable.nixosModules.home-manager
      sops-nix.nixosModules.sops
      lix-module.nixosModules.default
    ])
    ++ (map mylib.relativeToRoot [
      "modules/nixos"
      "hosts/cocytus"
    ]);
    home-modules = (map mylib.relativeToRoot [ "modules/home" ]);
    home-root = mylib.relativeToRoot "hosts/cocytus/home";
    nixpkgs = inputs.nixpkgs-stable;
    home-manager = inputs.home-manager-stable;
  };
in
{
  nixosConfigurations = {
    "${name}" = mylib.nixosSystem (
      {
        fake-secrets = false;
        variables = {
          system = {
            type = "server";
          };
        };
      }
      // modules
      // args
    );
  };
}
