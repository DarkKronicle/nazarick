{ pkgs, lib, ... }:
{
  environment.systemPackages = with pkgs; [
    neovim
    borgbackup
    ntfs3g
    gparted
    cryptsetup
    maliit-framework
    maliit-keyboard
    git
    rsync
    firefox
    yazi
  ];

  # `install-iso` adds wireless support that
  # is incompatible with networkmanager.
  # networking.wireless.enable = mkForce false;
  networking.networkmanager.enable = true;
  networking.wireless.enable = lib.mkForce false;

  networking.hostName = "recovery";

  services.desktopManager.plasma6.enable = true;
  services.xserver = {
    enable = true;

    # Automatically login as nixos.
    displayManager = {
      sddm.enable = true;
      autoLogin = {
        enable = true;
        user = "nixos";
      };
    };
  };

  nazarick = {
    suites = {
      common = {
        enable = true;
      };
    };
  };

  powerManagement.enable = true;
  hardware.pulseaudio.enable = true;

  documentation.doc.enable = lib.mkOverride 500 true;

  fonts.fontconfig.enable = lib.mkOverride 500 false;

  system.activationScripts.installerDesktop =
    let

      # Comes from documentation.nix when xserver and nixos.enable are true.
      manualDesktopFile = "/run/current-system/sw/share/applications/nixos-manual.desktop";

      homeDir = "/home/nixos/";
      desktopDir = homeDir + "Desktop/";
    in
    ''
      mkdir -p ${desktopDir}
      chown nixos ${homeDir} ${desktopDir}

      ln -sfT ${manualDesktopFile} ${desktopDir + "nixos-manual.desktop"}
      ln -sfT ${pkgs.gparted}/share/applications/gparted.desktop ${desktopDir + "gparted.desktop"}
    '';
}
