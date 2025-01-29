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

    boot.kernelPackages = pkgs.linuxPackages_zen;
    boot.initrd.systemd.enable = true;

    # TODO: move this
    hardware.usb-modeswitch.enable = true;

    environment.systemPackages = [
      pkgs.cifs-utils
    ];

    networking.hostName = "tabula";
    time.timeZone = "America/Denver";

    sops.secrets."user/darkkronicle/password".neededForUsers = true;

    hardware.uinput.enable = true;

    # TODO: move this
    # for ags
    services.upower.enable = true;
    services.gvfs.enable = true;

    services.udev.extraRules = ''
      SUBSYSTEM=="usb", ATTRS{idVendor}=="0483", MODE="0666"
      SUBSYSTEM=="usb_device", ATTRS{idVendor}=="0483", MODE="0666"
    '';

    nazarick.users = {
      mutableUsers = false;

      user."darkkronicle" = {
        extraGroups = [
          "wheel"
          "networkmanager"
          "uinput" # TODO: remove
          "input" # TODO: remove
          "adbusers"
          "dialout"
        ];
        uid = 1000;
        extraOptions = {
          hashedPasswordFile = config.sops.secrets."user/darkkronicle/password".path;
        };
      };
    };

    programs.adb.enable = true;

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
        boot.plymouth.enable = false;
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
        btrbk = {
          enable = true;
          subvolume = {
            "@keep" = { };
            "@transient" = { };
          };
        };
      };
      network = {
        dnscrypt = enabled;
        firewall = {
          enable = true;
          kdeconnect = true;
          nordvpn = true;
          syncthing = true;
        };
        nordvpn = enabled;
      };
      service = {
        microsocks = enabled;
        netbird = enabled;
      };
      workspace = {
        common = enabled;
        impermanence = enabled;
        gui = {
          common = enabled;
          steam = enabled;
          wine = enabled;
          fcitx = enabled;
          sway = enabled;
          sddm = {
            enable = true;
            defaultSession = "sway";
          };
        };
        service = {
          borg = {
            enable = true;
            sshFile = "/home/darkkronicle/.ssh/id_tabula";
          };
        };
        cli.common = enabled;
        security = {
          firejail = enabled;
        };
      };
    };

    hardware.graphics.extraPackages = with pkgs; [
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
