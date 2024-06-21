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
            inputs.nix-index-database.hmModules.nix-index
            # inputs.sops-nix.homeManagerModules.sops
          ];
        }
      ]
      ++ (with inputs; [
        # persist-retro.nixosModules.persist-retro
        home-manager.nixosModules.home-manager
        # sops-nix.nixosModules.sops
        lix-module.nixosModules.default
      ])
      ++ (map mylib.relativeToRoot [
        "modules/nixos"
        "hosts/cocytus"
      ]);
    home-modules = (map mylib.relativeToRoot [ "modules/home" ]);
    home-root = mylib.relativeToRoot "hosts/cocytus/home";
    nixpkgs = inputs.nixpkgs-stable;
  };
in
{
  nixosConfigurations = {
    "${name}" = mylib.nixosSystem ({ fake-secrets = true; } // modules // args);
  };
}
