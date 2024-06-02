{
  pkgs,
  lib,
  mylib,
  inputs,
  mypkgs,
  ...
}:
let
  inherit (mylib) enabled;
in
{
  imports = [ ./hardware.nix ] ++ (mylib.scanPaths ./specialisation);

  nixpkgs.config.allowUnfree = true;

  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "tabula";
  time.timeZone = "America/Denver";

  nazarick = {
    core = {
      common = enabled;
      sops = enabled;
    };
    system = {
      boot.grub = true;
      common = true;
      desktop = true;
      cleanup = enabled;
      misc = {
        tlp = true;
        thermald = true;
      };
      nvidia = {
        enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
    network = {
      dnscrypt = enabled;
      firewall = {
        enable = true;
        kdeconnect = true;
        nordvpn = true;
      };
      nordvpn = enabled;
    };
    workspace = {
      user = enabled;
      impermanence = enabled;
      gui = {
        common = enabled;
        plasma = enabled;
        steam = enabled;
        wine = enabled;
        fcitx = enabled;
      };
      service = {
        spotifyd = enabled;
        kanata = enabled;
        borg = enabled;
      };
      cli.common = enabled;
    };
  };

  hardware.opengl.extraPackages = with pkgs; [
    intel-vaapi-driver
    libvdpau-va-gl
    intel-media-driver
  ];

  networking = {
    networkmanager.enable = true;
  };

  programs.java.enable = true;
  programs.dconf.enable = true;

  environment.systemPackages =
    with mypkgs; [
      kamite-bin
      ltspice
      tomb
      (tomato-c.override {
        # Home manager simlinks mpv configs, so this forces a fresh config.
        # This is mainly an issue with sounds because it pulls up a window in my config
        mpv = pkgs.wrapMpv pkgs.mpv-unwrapped {
          extraMakeWrapperArgs = [
            "--add-flags"
            "--config-dir=/home/darkkronicle/.config/mpv2"
          ];
        };
      })
    ] ++ (with pkgs;
    [
      wget
      git
      git-credential-oauth
      gcc
      brave
      qbittorrent
      gnumake
      matlab
      playerctl
      rnote
      prismlauncher

      rust-analyzer
      devenv

      anki

      qalculate-qt
      libqalculate
      gparted
      ntfs3g
      pipes-rs

      wl-clipboard
      waveforms
      mecab # TODO: Anki this up
      bandwhich
      yt-dlp
      ledger
      nh

      (texlive.combine { inherit (texlive) scheme-medium circuitikz; })
      # TODO: add my catppuccin theme or make a repo
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
      gtrash

      kdePackages.partitionmanager
      dust
      compsize
    ])
    ++ [ inputs.faerber.packages.x86_64-linux.faerber ];

  environment.shells = with pkgs; [ nushell ];

  programs.fuse.userAllowOther = true;

  system.stateVersion = "23.11"; # Did you read the comment?
}
