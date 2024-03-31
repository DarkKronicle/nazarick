{
  pkgs,
  lib,
  inputs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    neovim
    nazarick.operator-caska
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
    font-manager
    libqalculate
    qalculate-qt

    sops
    ssh-to-age

    kdePackages.partitionmanager
    dust
    compsize
  ];

  home-manager.sharedModules = with inputs; [ plasma-manager.homeManagerModules.plasma-manager ];

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

  # Password is already set to none
  users.users.nixos = {
    isNormalUser = true;
    home = "/home/nixos";
    group = "users";
    password = lib.mkForce "password";
    hashedPassword = lib.mkForce null;
    hashedPasswordFile = lib.mkForce null;
    initialPassword = lib.mkForce null;
    initialHashedPassword = lib.mkForce null;
  };

  nazarick = {
    suites = {
      common = {
        enable = true;
      };
    };
    user = {
      enable = false;
    };
    appearance = {
      plasma = {
        enable = true;
      };
    };
  };

  fonts.packages = with pkgs; [
    inter
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    noto-fonts-cjk-sans
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
  ];

  powerManagement.enable = true;
  hardware.pulseaudio.enable = true;

  documentation.doc.enable = lib.mkOverride 500 true;

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
