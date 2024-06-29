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
  imports = [ ./hardware.nix ];

  config = {

    nixpkgs.config.allowUnfree = true;
    services.openssh.enable = true;
    programs.mosh.enable = true;

    networking.hostName = "cocytus";
    time.timeZone = "America/Denver";

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };

    nazarick.users = {
      mutableUsers = true;

      user."darkkronicle" = {
        extraGroups = [ "wheel" ];
        uid = 1000;
      };
      user."${myvars.user.user2.name}" = {
        homeManagerFileName = "user2.nix";

        extraGroups = [ "wheel" ];
        uid = 1001;

        shell = pkgs.zsh;
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
      memoryPercent = 50;
    };

    # Frozen variables up ahead, don't touch 🥶🥶🥶🥶🥶
    # -----------------------------------------------
    system.stateVersion = "24.05"; # Don't change ♥‿♥
    # -----------------------------------------------
  };
}
