{ pkgs, nur, lib, nixos-hardware, config, inputs, ... }:
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

  # https://github.com/kessejones/dotfiles-nixos/blob/543756de674b4ad7e27f02991d171eb8d0956c10/hosts/desktop/modules/networking.nix
  networking = {
    hostName = "tabula"; # Define your hostname.
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.

    firewall = let
      tcpPorts = [22 24800 25565];
      wifiInterface = "wlp0s20f3";
      etherInterface = "eno1";
      networks = [
        "172.18.0.1/24"
        "192.168.0.1/24"
        "10.0.0.1/24"
      ];
    in {
      enable = false;
      interfaces.${wifiInterface} = {
        allowedTCPPorts = tcpPorts;
        allowedUDPPorts = [
          10001
          10002
          10011
          10012
        ];
      };
      interfaces.${etherInterface}.allowedTCPPorts = tcpPorts;

      extraCommands = let
        mkLocalRule = network: ''
          iptables -A nixos-vpn-killswitch -d ${network} -j ACCEPT
        '';

        localRules = builtins.concatStringsSep "\n" (builtins.map (
            n: (mkLocalRule n)
          )
          networks);

        killSwitchRule = ''
          # Flush old firewall rules
          iptables -D OUTPUT -j nixos-vpn-killswitch 2> /dev/null || true
          iptables -F "nixos-vpn-killswitch" 2> /dev/null || true
          iptables -X "nixos-vpn-killswitch" 2> /dev/null || true

          # Create chain
          iptables -N nixos-vpn-killswitch

          # Allow traffic on localhost
          iptables -A nixos-vpn-killswitch -o lo -j ACCEPT

          # Allow lan traffic
          ${localRules}

          # Allow connecition to vpn server
          iptables -A nixos-vpn-killswitch -p udp -m udp --dport 1194 -j ACCEPT
          iptables -A nixos-vpn-killswitch -p udp -m udp --dport 51820 -j ACCEPT

          # Allow connections tunneled over VPN
          iptables -A nixos-vpn-killswitch -o tun0 -j ACCEPT
          iptables -A nixos-vpn-killswitch -o wg0 -j ACCEPT

          # Disallow outgoing traffic by default
          iptables -A nixos-vpn-killswitch -j DROP

          # Enable killswitch
          iptables -A OUTPUT -j nixos-vpn-killswitch
        '';
      in ''
        # Enable killswitch by default
        ${killSwitchRule}
      '';

      extraStopCommands = ''
        iptables -D OUTPUT -j nixos-vpn-killswitch
      '';
    };

  };
  time.timeZone = "America/Denver";

  services.xserver.enable = true;
  services.printing.enable = true;

  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma6.enable = true;

  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  programs.dconf.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  services.pipewire.wireplumber.configPackages = [
    (pkgs.writeTextDir "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" ''
     bluez_monitor.properties = {
       ["bluez5.enable-sbc-xq"] = true,
       ["bluez5.enable-msbc"] = true,
       ["bluez5.enable-hw-volume"] = true,
       ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]",
       ["bluez5.roles"] = "[ a2dp_sink ]",
       ["bluez5.hfphsp-backend"] = "none",
     }
     bluez_monitor.rules = {
       {
         apply_properties = {
           ["bluez5.auto-connect"] = "[ a2dp_sink ]",
           ["bluez5.hw-volume"] = "[ a2dp_sink ]",
         },
       },
     }
     '')
  ];

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
    brave
    qbittorrent
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
    nix-output-monitor
    libreoffice-qt
    hunspell # spell check for libreoffice
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
      nordvpn = {
        enable = true;
      };
    };
  };

  system.stateVersion = "23.11"; # Did you read the comment?

}
