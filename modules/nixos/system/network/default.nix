{ config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  inherit (lib.nazarick) mkBoolOpt;

  cfg = config.nazarick.system.network;
in
{
  options.nazarick.system.network = {
    enable = mkBoolOpt false "Enable wifi configuration.";
    kdeconnect = mkBoolOpt false "Open KDE Connect's ports";
    nordvpn = mkBoolOpt false "Allow NordVPN's ports";
  };
  config = mkIf cfg.enable {

    networking = {
      nameservers = [
        "127.0.0.1"
        "::1"
      ];
      networkmanager.dns = "none";
    };

    services.dnscrypt-proxy2 = {
      enable = true;
      settings = {
        # TODO: Maybe setup cloaking for local servers?
        # TODO: nordvpn requires dns server to be set to 127.0.0.1 to use dnscrypt, so maybe figure out how to do that declaritivaly?
        ipv4_servers = true;
        ipv6_servers = true;
        block_ipv6 = false;
        doh_servers = true;

        # I had some issues here, and it turns out these 2 both have to be on
        # for quad9
        require_nofilter = false; # quad9 has some nice security filters
        require_dnssec = true;

        sources.quad9-resolvers = {
          urls = [
            "https://quad9.net/dnscrypt/quad9-resolvers.md"
            "https://raw.githubusercontent.com/Quad9DNS/dnscrypt-settings/main/dnscrypt/quad9-resolvers.md"
          ];
          minisign_key = "RWQBphd2+f6eiAqBsvDZEBXBGHQBJfeG6G+wJPPKxCZMoEQYpmoysKUN";
          cache_file = "/var/lib/dnscrypt-proxy/quad9-resolvers.md";
          prefix = "quad9-";
        };
      };
    };

    # https://github.com/NixOS/nixpkgs/issues/170573
    # TLDR: when using StateDirectory, systemd will strong arm control for it.
    # it creates a /var/lib/private thing, confusing, bind mounting that will
    # freak out because it's using a dynamic user. Last thing we want
    # is for DNS to not work on the system. Setting ReadWritePaths gives
    # us full control, and allows us to persist it correctly.
    systemd.services.dnscrypt-proxy2.serviceConfig = {
      StateDirectory = lib.mkForce "";
      ReadWritePaths = "/var/lib/dnscrypt-proxy";
    };

    # Make sure this directory exists so the service doesn't fail on boot
    systemd.tmpfiles.rules = [ "d /var/lib/dnscrypt-proxy 0755 root root -" ];

    networking.firewall = lib.mkMerge [
      {
        enable = true;
        allowedTCPPortRanges = mkIf cfg.kdeconnect [
          {
            from = 1714;
            to = 1764;
          } # KDE Connect
        ];
        allowedUDPPortRanges = mkIf cfg.kdeconnect [
          {
            from = 1714;
            to = 1764;
          } # KDE Connect
        ];
      }
      (mkIf cfg.nordvpn {
        checkReversePath = false;
        allowedTCPPorts = [ 443 ];
        allowedUDPPorts = [ 1194 ];
      })
    ];
  };
}
