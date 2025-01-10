{
  description = "The Great Tomb of Nazarick";

  inputs = {

    # --------------------
    # Main channels
    # --------------------

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-stable = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # --------------------
    # System functionality and utilities
    # --------------------

    # impermanence.url = "github:nix-community/impermanence";
    impermanence.url = "github:nix-community/impermanence";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    haumea = {
      url = "github:nix-community/haumea/v0.2.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak?ref=latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --------------------
    # Application specific inputs
    # --------------------

    nvim-cats = {
      url = "github:DarkKronicle/nvim-dotfiles";
      # Make sure nvim never breaks without my consent
      # inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-arkenfox = {
      url = "github:dwarfmaster/arkenfox-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    blocklist = {
      url = "github:StevenBlack/hosts?dir=alternates/gambling-porn";
      flake = false;
    };

    # --------------------
    # Specific applications
    # --------------------

    faerber.url = "github:nekowinston/faerber";

    # NOTE: locked because AGS 2.0 is a major overhaul
    ags = {
      url = "github:Aylur/ags?rev=60180a184cfb32b61a1d871c058b31a3b9b0743d";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mint = {
      url = "github:trumank/mint";
    };

    waveforms = {
      url = "github:liff/waveforms-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-matlab = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "gitlab:doronbehar/nix-matlab";
    };

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs: import ./outputs inputs;

}
