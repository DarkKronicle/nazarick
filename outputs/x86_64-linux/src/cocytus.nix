{
  # NOTE: the args not used in this file CAN NOT be removed!
  # because haumea pass argument lazily,
  inputs,
  lib,
  mylib,
  myvars,
  system,
  genSpecialArgs,
  ...
}@args:
let
  name = "cocytus";
  modules = {
    nix-modules =
      [
        {
          home-manager.sharedModules = [
            inputs.plasma-manager.homeManagerModules.plasma-manager # TODO: This needs to be installed even if not used bc of how I'm sourcing files
            inputs.nix-index-database.hmModules.nix-index
            inputs.sops-nix.homeManagerModules.sops
          ];
        }
      ]
      ++ (with inputs; [
        # persist-retro.nixosModules.persist-retro
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
    "${name}" = mylib.nixosSystem ({ fake-secrets = false; } // modules // args);
  };
}
