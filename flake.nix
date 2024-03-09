{
  description = "The Great Tomb of Nazarick";

  inputs = {

    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-flake = {
      url = "github:snowfallorg/flake";
      # Flake requires some packages that aren't on 22.05, but are available on unstable.
      inputs.nixpkgs.follows = "unstable";
    };

    # home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    
    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-matlab = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "gitlab:doronbehar/nix-matlab";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    nur.url = "github:nix-community/NUR";
  };

  outputs = inputs: let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;
        snowfall = {
          meta = {
            name = "nazarick";
            title = "The Great Tomb of Nazarick";
          };

          namespace = "nazarick";
      };
    };
    in
    lib.mkFlake {
      channels-config = {
        allowUnfree = true;
        permittedUnsecurePackages = [
          "router-1.19.0"
        ];
      };

      overlays = with inputs; [
        snowfall-flake.overlays.default
        fenix.overlays.default
        nix-matlab.overlay
        nur.overlay
      ];

      systems.modules.nixos = with inputs; [
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        nur.nixosModules.nur
      ];

      deploy = lib.mkDeploy { inherit (inputs) self; };
    };

}
