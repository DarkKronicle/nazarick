{ config, lib, ... }:
with lib;
with lib.nazarick;
let
  cfg = config.nazarick.system.network;
in
{
  options.nazarick.system.network = with types; {
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
        ipv4_servers = true;
        ipv6_servers = true;
        block_ipv6 = false;

        doh_servers = true;

        require_dnssec = true;
        server_names = [
          "quad9-dnscrypt-ip4-filter-pri"
          "quad9-dnscrypt-ip6-filter-pri"
          "doh-ip4-port443-filter-pri"
          "doh-ip6-port443-filter-pri"
          "doh-ip4-port5053-filter-pri"
          "doh-ip6-port5053-filter-pri"
        ];
        sources.quad9-resolvers = {
          urls = [ "https://www.quad9.net/quad9-resolvers.md" ];
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

    networking.firewall = mkMerge [
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
