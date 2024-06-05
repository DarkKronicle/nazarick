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
      common = enabled;
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
      security = {
        firejail = enabled;
      };
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

  programs.fuse.userAllowOther = true;

  # Frozen variables up ahead, don't touch 🥶🥶🥶🥶🥶
  # -----------------------------------------------
  system.stateVersion = "23.11"; # Don't change ♥‿♥
  # -----------------------------------------------
}
