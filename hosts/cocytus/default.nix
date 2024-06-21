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

    networking.hostName = "cocytus";
    time.timeZone = "America/Denver";

    nazarick.users = {
      mutableUsers = true;

      user."darkkronicle" = {
        extraGroups = [ "wheel" ];
        uid = 1000;
      };

    };

    nazarick = {
      core = {
        common = enabled;
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
        nordvpn = enabled;
      };
      workspace = {
        cli.common = enabled;
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
