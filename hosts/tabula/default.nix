{
  pkgs,
  config,
  mylib,
  myvars,
  ...
}:
let
  inherit (mylib) enabled;
in
{
  imports = [ ./hardware.nix ] ++ (mylib.scanPaths ./specialisation);

  config = {

    nixpkgs.config.allowUnfree = true;

    boot.kernelPackages = pkgs.linuxPackages_zen;
    boot.initrd.systemd.enable = true;

    networking.hostName = "tabula";
    time.timeZone = "America/Denver";

    sops.secrets."user/darkkronicle/password".neededForUsers = true;

    hardware.uinput.enable = true;

    # for ags
    services.upower.enable = true;
    services.gvfs.enable = true;

    nazarick.users = {
      mutableUsers = false;

      user."darkkronicle" = {
        extraGroups = [
          "wheel"
          "networkmanager"
          "uinput" # TODO: remove
          "input" # TODO: remove
        ];
        uid = 1000;
        extraOptions = {
          hashedPasswordFile = config.sops.secrets."user/darkkronicle/password".path;
        };
      };
    };

    nazarick = {
      core = {
        common = enabled;
        sops = {
          enable = true;
          keyFile = "/persist/system/var/lib/sops-nix/keys.txt";
        };
      };
      system = {
        boot.grub.enable = true;
        boot.plymouth.enable = true;
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
        impermanence = enabled;
        gui = {
          common = enabled;
          plasma = enabled;
          steam = enabled;
          wine = enabled;
          fcitx = enabled;
        };
        service = {
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
  };
}
