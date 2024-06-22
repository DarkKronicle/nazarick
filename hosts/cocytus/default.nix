{
  pkgs,
  config,
  mylib,
  ...
}:
let
  inherit (mylib) enabled;
in
{
  imports = [ ./hardware.nix ];

  config = {

    nixpkgs.config.allowUnfree = true;
    services.openssh.enable = true;

    networking.hostName = "cocytus";
    time.timeZone = "America/Denver";

    nazarick.users = {
      mutableUsers = true;

      user."darkkronicle" = {
        extraGroups = [ "wheel" ];
        uid = 1000;
      };
    };

    hardware = {
      opengl = {
        enable = true;
        extraPackages = [
          pkgs.intel-media-driver
          pkgs.intel-media-sdk # Doesn't support vpl
        ];
      };
    };

    nazarick = {
      core = {
        common = enabled;
        nix.update-registry = false;
        sops = {
          enable = true;
          keyFile = "/var/lib/sops-nix/keys.txt";
        };
      };
      system = {
        boot.systemd-boot.enable = true;
        common = true;
        desktop = true;
        # cleanup = enabled;
      };
      network = {
        dnscrypt = enabled;
        firewall = {
          enable = true;
          nordvpn = true;
        };
        nordvpn = {
          enable = true;
          autoMeshnetRestart = true;
        };
      };
      workspace = {
        cli.common = enabled;
        service = {
          jellyfin = enabled;
        };
      };
    };

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      priority = 5;
    };

    # Frozen variables up ahead, don't touch 🥶🥶🥶🥶🥶
    # -----------------------------------------------
    system.stateVersion = "24.05"; # Don't change ♥‿♥
    # -----------------------------------------------
  };
}
