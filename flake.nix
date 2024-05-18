{
  description = "The Great Tomb of Nazarick";

  inputs = {

    # nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    waveforms.url = "github:liff/waveforms-flake";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Generate System Images
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    nix-matlab = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "gitlab:doronbehar/nix-matlab";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    plasma-manager.url = "github:pjones/plasma-manager";
    plasma-manager.inputs.nixpkgs.follows = "nixpkgs";
    plasma-manager.inputs.home-manager.follows = "home-manager";

    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # There is very little reason to have this be a private repository, but makes
    # me feel better nonetheless. 
    mysecrets = {
      url = "git+ssh://git@gitlab.com/DarkKronicle/nix-sops.git?ref=main&shallow=1";
      flake = false;
    };

    impermanence.url = "github:nix-community/impermanence";
    persist-retro.url = "github:Geometer1729/persist-retro";

    faerber.url = "github:nekowinston/faerber";

    lix = {
      url = "git+https://git@git.lix.systems/lix-project/lix?ref=refs/tags/2.90-beta.1";
      flake = false;
    };
    lix-module = {
      url = "git+https://git.lix.systems/lix-project/nixos-module";
      inputs.lix.follows = "lix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvim-cats = {
      url = "github:DarkKronicle/nvim-dotfiles";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs =
    inputs:
    let
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
        permittedUnsecurePackages = [ "router-1.19.0" ];
      };

      overlays = with inputs; [
        (
          _: super:
          let
            pkgs = fenix.inputs.nixpkgs.legacyPackages.${super.system};
          in
          fenix.overlays.default pkgs pkgs
        )
        nix-matlab.overlay
        # inputs.neovim-nightly-overlay.overlay
      ];

      systems.modules.nixos = with inputs; [
        impermanence.nixosModules.impermanence
        # persist-retro.nixosModules.persist-retro
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        inputs.waveforms.nixosModule
        inputs.lix-module.nixosModules.default
      ];

      # homes.modules = with inputs; [ plasma-manager.homeManagerModules.plasma-manager ];

      deploy = lib.mkDeploy { inherit (inputs) self; };
    };
}
