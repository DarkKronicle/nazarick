{
  pkgs,
  nur,
  lib,
  nixos-hardware,
  config,
  inputs,
  ...
}:
with lib;
with lib.nazarick;
{
  imports = [
    ./hardware.nix
    ./system.nix
  ];

  home-manager.sharedModules = with inputs; [ plasma-manager.homeManagerModules.plasma-manager ];

  networking.hostName = "tabula";

  nazarick = {
    suites = {
      desktop = enabled;
    };
    system = {
      boot = {
        grub = true;
      };
      nvidia = {
        enable = true;
        nvidiaBusId = "PCI:1:0:0";
        intelBusId = "PCI:0:2:0";
      };
    };
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
      cli = {
        enable = true;
      };
      nordvpn = {
        enable = true;
      };
    };
  };

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/darkkronicle/.config/sops/age/keys.txt";

  # https://github.com/kessejones/dotfiles-nixos/blob/543756de674b4ad7e27f02991d171eb8d0956c10/hosts/desktop/modules/networking.nix
  networking = {
    networkmanager.enable = true;
  };

  # firewall = let
  # tcpPorts = [22 24800 25565];
  # wifiInterface = "wlp0s20f3";
  # etherInterface = "eno1";
  # networks = [
  # "172.18.0.1/24"
  # "192.168.0.1/24"
  # "10.0.0.1/24"
  # ];
  # in {
  # enable = true;
  # interfaces.${wifiInterface} = {
  # allowedTCPPorts = tcpPorts;
  # allowedUDPPorts = [
  # 10001
  # 10002
  # 10011
  # 10012
  # ];
  # };
  # interfaces.${etherInterface}.allowedTCPPorts = tcpPorts;
  # 
  # extraCommands = let
  # mkLocalRule = network: ''
  # iptables -A nixos-vpn-killswitch -d ${network} -j ACCEPT
  # '';
  # 
  # localRules = builtins.concatStringsSep "\n" (builtins.map (
  # n: (mkLocalRule n)
  # )
  # networks);
  # 
  # killSwitchRule = ''
  # # Flush old firewall rules
  # iptables -D OUTPUT -j nixos-vpn-killswitch 2> /dev/null || true
  # iptables -F "nixos-vpn-killswitch" 2> /dev/null || true
  # iptables -X "nixos-vpn-killswitch" 2> /dev/null || true
  # 
  # # Create chain
  # iptables -N nixos-vpn-killswitch
  # 
  # # Allow traffic on localhost
  # iptables -A nixos-vpn-killswitch -o lo -j ACCEPT
  # 
  # # Allow lan traffic
  # ${localRules}
  # 
  # # Allow connecition to vpn server
  # iptables -A nixos-vpn-killswitch -p udp -m udp --dport 1194 -j ACCEPT
  # iptables -A nixos-vpn-killswitch -p udp -m udp --dport 51820 -j ACCEPT
  # 
  # # Allow connections tunneled over VPN
  # iptables -A nixos-vpn-killswitch -o tun0 -j ACCEPT
  # iptables -A nixos-vpn-killswitch -o wg0 -j ACCEPT
  # 
  # # Disallow outgoing traffic by default
  # iptables -A nixos-vpn-killswitch -j DROP
  # 
  # # Enable killswitch
  # iptables -A OUTPUT -j nixos-vpn-killswitch
  # '';
  # in ''
  # # Enable killswitch by default
  # ${killSwitchRule}
  # '';
  # 
  # extraStopCommands = ''
  # iptables -D OUTPUT -j nixos-vpn-killswitch
  # '';
  # };

  # };

  services.xserver.enable = true;

  services.xserver.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    git-credential-oauth
    gcc
    firefox
    brave
    qbittorrent
    vesktop
    gnumake
    nazarick.operator-caska
    matlab
    playerctl
    nheko
    nazarick.ltspice
    rnote
    nixfmt-rfc-style
    prismlauncher
    nazarick.anki
    qalculate-qt
    wl-clipboard
    nix-output-monitor
    libreoffice-qt
    hunspell # spell check for libreoffice
    texlive.combined.scheme-medium
    pdfarranger
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

  system.stateVersion = "23.11"; # Did you read the comment?
}
