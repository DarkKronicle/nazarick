{ pkgs, config, ... }:
{
  config = {
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.forwarding" = 1;
    };

    networking.firewall.extraCommands = ''
      iptables -P FORWARD DROP
      iptables -A INPUT -m state --state INVALID -j DROP
      iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
      iptables -A FORWARD -i host0 -o wt0 -j ACCEPT
      iptables -A FORWARD -i wt0 -o host0 -j ACCEPT
      iptables -t nat -A POSTROUTING -s 10.200.0.0/24 -o wt0 -j MASQUERADE
    '';

    sops.secrets."nordvpn/privatekey" = { };

    networking.firewall.trustedInterfaces = [ "host0" ];

    systemd.services."network-namespaces-init" = {
      enable = true;

      path = with pkgs; [
        wireguard-tools
        iptables
        iproute2
        nushell
        host
      ];

      script = "nu ${./netns.nu} up ${config.sops.secrets."nordvpn/privatekey".path}";

      preStart = "until host google.com; do sleep 1; done";

      # default.target here because we have to wait for internet
      # (which is typically under a secrets which is under pam which is under login)
      wantedBy = [ "default.target" ];

      wants = [
        "network-online.target"
        "nss-lookup.target"
      ];

      after = [
        "network-online.target"
        "nss-lookup.target"
      ];

      serviceConfig = {
        Type = "oneshot";
      };
    };
  };
}
