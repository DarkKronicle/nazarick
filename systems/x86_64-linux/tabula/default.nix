{
  pkgs,
  lib,
  inputs,
  ...
}:
with lib;
with lib.nazarick;
{
  imports = [ ./hardware.nix ];

  home-manager.sharedModules = with inputs; [
    plasma-manager.homeManagerModules.plasma-manager
    impermanence.nixosModules.home-manager.impermanence
    nix-index-database.hmModules.nix-index
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "tabula";
  time.timeZone = "America/Denver";

  nazarick = {
    user = {
      enable = true;
    };
    appearance = {
      plasma = {
        enable = true;
      };
    };
    suites = {
      desktop = enabled;
      document = enabled;
      impermanence = enabled;
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
      fcitx = {
        enable = true;
      };
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
      cleanup = {
        enable = true;
      };
    };
    specialisation = {
      powersave = {
        enable = true;
      };
    };
  };
  hardware.opengl.extraPackages = with pkgs; [
    intel-vaapi-driver
    libvdpau-va-gl
    intel-media-driver
  ];

  # xdg.autostart.enable = false;

  # sops.defaultSopsFormat = "yaml";
  # sops.age.keyFile = "/home/darkkronicle/.config/sops/age/keys.txt";
  sops = {
    defaultSopsFile = "${builtins.toString inputs.mysecrets}/secrets.yaml";
    age = {
      keyFile = "/persist/system/var/lib/sops-nix/keys.txt";
    };
  };

  networking = {
    networkmanager.enable = true;
  };

  services.xserver.enable = true;

  services.xserver.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  programs.java.enable = true;
  programs.dconf.enable = true;

  environment.systemPackages =
    with pkgs;
    [
      wget
      git
      git-credential-oauth
      gcc
      firefox
      brave
      qbittorrent
      vesktop
      gnumake
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
      gparted
      ntfs3g
      pipes-rs

      wl-clipboard
      waveforms
      mecab

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

      filezilla
      sops
      ssh-to-age
      gtrash

      kdePackages.partitionmanager
      dust
      compsize
    ]
    ++ [ inputs.faerber.packages.x86_64-linux.faerber ];

  powerManagement.enable = true;
  services.system76-scheduler.settings.cfsProfiles.enable = true;

  environment.shells = with pkgs; [ nushell ];

  programs.fuse.userAllowOther = true;

  system.stateVersion = "23.11"; # Did you read the comment?
}
