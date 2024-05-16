{
  pkgs,
  lib,
  inputs,
  config,
  ...
}:
let
  inherit (lib.nazarick) enabled;
in
{

  imports = [
    ./specialisation.nix
  ];

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
    libqalculate
    qalculate-qt

    sops
    ssh-to-age

    kdePackages.partitionmanager
    dust
    compsize
  ];

  isoImage.squashfsCompression = "zstd -Xcompression-level 6";

  # This essentially makes it so password not required
  # TODO: Probably not the *best* idea, but on this minimal system it should be fine 
  security.polkit.extraConfig = lib.mkIf (config.specialisation != { }) ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';


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
    bundles = {
      common = {
        enable = true;
      };
    };
    user = {
      enable = false;
    };
    desktop = {
      plasma = {
        enable = true;
      };
      fonts = {
        enable = true;
      };
      sddm = {
        enable = true;
      };
    };
    system = {
      network = {
        enable = true;
      };
      memory = enabled;
    };
  };

  powerManagement.enable = true;
  hardware.pulseaudio.enable = true;

  documentation.doc.enable = lib.mkOverride 500 true;

  environment.shells = with pkgs; [ nushell ];

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

      cp -f ${./mount.nu} ${desktopDir + "mount.nu"}
      chmod +x ${desktopDir + "mount.nu"}

      ln -sfT ${manualDesktopFile} ${desktopDir + "nixos-manual.desktop"}
      ln -sfT ${pkgs.gparted}/share/applications/gparted.desktop ${desktopDir + "gparted.desktop"}
    '';
}
