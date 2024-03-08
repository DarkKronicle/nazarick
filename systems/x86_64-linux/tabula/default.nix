{ pkgs, lib, nixos-hardware, config, inputs, ... }:
with lib; with lib.internal; {
  imports = [ 
    ./hardware.nix 
    # inputs.sops-nix.nixosModules.sops
  ];

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/darkkronicle/.config/sops/age/keys.txt";

  sops.secrets."spotifyd/username" = {
    owner = "darkkronicle";
  };
  sops.secrets."spotifyd/password" = {
    owner = "darkkronicle";
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tabula"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  time.timeZone = "America/Denver";

  services.xserver.enable = true;
  services.printing.enable = true;

  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma6.enable = true;

  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  programs.dconf.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    #jack.enable = true;
  };
  
  fileSystems = {
    "/".options = [ "compress=zstd" "noatime" ];
    "/home" = {
      options = [ "compress=zstd" "noatime" ];
      neededForBoot = true; # Get keys from here
    };
    "/nix".options = [ "compress=zstd" "noatime" ];
    "/boot".options = [ "umask=0077" ];
    "/swap".options = [ "noatime" ];
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  # GPU
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
    ];
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = { 
    modesetting.enable = true;

    powerManagement.finegrained = false;
    powerManagement.enable = false;

    open = false;
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      sync.enable = true;

      nvidiaBusId = "PCI:1:0:0";
      intelBusId = "PCI:0:2:0";
    };
  };

  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    git-credential-oauth
    gcc
    firefox
    vesktop
    kitty
    gnumake
    nazarick.operator-caska
    fzf
    unzip
    ripgrep
    matlab
    playerctl
    nheko
    nazarick.ltspice
    fd
    prismlauncher
    nazarick.anki
    wl-clipboard
    (pkgs.mumble.override { pulseSupport = true; })
    # nazarick.mint - I give up, this isn't working
    (fenix.complete.withComponents [
     "cargo"
     "clippy"
     "rust-src"
     "rustc"
     "rustfmt"
    ])
      rust-analyzer-nightly
  ];

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      noto-fonts-cjk-sans
  ];

  nazarick = {
    apps = {
      steam = {
        enable = true;
      };
      wine = {
        enable = true;
      };
      spotifyd = {
        enable = true;
      };
    };
    tools = {
      kanata = {
        enable = true;
      };
    };
  };

  system.stateVersion = "23.11"; # Did you read the comment?

}
