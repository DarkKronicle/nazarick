{
  pkgs,
  lib,
  nixos-hardware,
  config,
  inputs,
  ...
}:
with lib;
with lib.nazarick;
{
  imports = [
    ./hardware.nix
    ./system.nix
  ];

  home-manager.sharedModules = with inputs; [
    plasma-manager.homeManagerModules.plasma-manager
    inputs.nix-index-database.hmModules.nix-index
  ];

  networking.hostName = "tabula";

  nazarick = {
    suites = {
      desktop = enabled;
    };
    system = {
      boot = {
        grub = true;
      };
      nvidia = {
        enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
    apps = {
      steam = {
        enable = true;
      };
      wine = {
        enable = true;
      };
      spotifyd = {
        enable = true;
      };
    };
    tools = {
      kanata = {
        enable = true;
      };
      cli = {
        enable = true;
      };
      nordvpn = {
        enable = true;
      };
    };
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/darkkronicle/.config/sops/age/keys.txt";

  networking = {
    networkmanager.enable = true;
  };

  services.xserver.enable = true;

  services.xserver.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    git-credential-oauth
    gcc
    firefox
    brave
    qbittorrent
    vesktop
    gnumake
    nazarick.operator-caska
    matlab
    playerctl
    nheko
    nazarick.ltspice
    rnote
    nixfmt-rfc-style
    prismlauncher
    nazarick.anki
    qalculate-qt
    libqalculate
    wl-clipboard
    nix-output-monitor
    libreoffice-qt
    hunspell # spell check for libreoffice
    texlive.combined.scheme-medium
    pdfarranger
    (pkgs.mumble.override { pulseSupport = true; })
    # nazarick.mint - I give up, this isn't working
    (fenix.complete.withComponents [
      "cargo"
      "clippy"
      "rust-src"
      "rustc"
      "rustfmt"
    ])
    rust-analyzer-nightly
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-cjk-sans
  ];

  system.stateVersion = "23.11"; # Did you read the comment?
}
