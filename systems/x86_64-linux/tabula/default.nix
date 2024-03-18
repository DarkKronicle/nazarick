{
  pkgs,
  lib,
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
    nix-index-database.hmModules.nix-index
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "tabula";

  nazarick = {
    user = {
      enable = true;
    };
    suites = {
      desktop = enabled;
      document = enabled;
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
      network = {
        enable = true;
        kdeconnect = true;
        nordvpn = true;
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
      borg = {
        enable = true;
      };
    };
    specialisation = {
      powersave = {
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

  programs.java.enable = true;

  environment.systemPackages = with pkgs; [
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
    nazarick.kamite
    matlab
    playerctl
    nheko
    nazarick.ltspice
    rnote
    prismlauncher

    nazarick.anki

    qalculate-qt
    libqalculate

    wl-clipboard

    (texlive.combine { inherit (texlive) scheme-medium circuitikz; })
    (pkgs.mumble.override { pulseSupport = true; })
    # nazarick.mint # - I give up, this isn't working
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
    inter
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-cjk-sans
  ];

  system.stateVersion = "23.11"; # Did you read the comment?
}
