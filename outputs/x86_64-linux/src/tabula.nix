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
  name = "tabula";
  modules = {
    nix-modules =
      [
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
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        waveforms.nixosModule
        lix-module.nixosModules.default
      ])
      ++ (map mylib.relativeToRoot [
        "modules/nixos"
        "hosts/tabula"
      ]);
    home-modules = (map mylib.relativeToRoot [ "modules/home" ]);
    home-root = mylib.relativeToRoot "hosts/tabula/home";
  };
in
{
  nixosConfigurations = {
    "${name}" = mylib.nixosSystem (
      {
        fake-secrets = false;
        headless = true;
        variables = {
          system = {
            type = "laptop";
          };
        };
      }
      // modules
      // args
    );
  };
}
