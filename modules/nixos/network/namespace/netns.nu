# Adapted from
# https://github.com/adombeck/nordvpn-netns

# The WireGuard interface IP address. Defaults to the address which
# the `nordvpn` command assigns to the interface (10.5.0.2/32).
const WG_IP = "10.5.0.2/32"
const WG_NAME = "nordvpn"
const WG_COUNTRY = "us"

def get-servers [--limit: int = 10] {
    http get $"https://api.nordvpn.com/v1/servers/recommendations?filters[country_id]=($WG_COUNTRY)&limit=($limit)&[servers_technologies][identifier]=wireguard_udp&[servers_groups][identifier]=P2P"
}

def "shared down" [] {
    print $"Stopping namespace shared"
    try {
        ip link set down dev shared0
    }
    try {
        ip link delete shared0
    }
    try {
        ip -n shared link set down dev shared1
    }
    try {
        ip -n shared link delete shared1
    }
    try {
        ip netns del shared
    }
    print $"Namespace shared is down"
}

def "nordvpn down" [] {
    print $"Stopping namespace ($WG_NAME)"
    try {
        ip -n $WG_NAME link set down dev $WG_NAME
    }
    try {
        ip -n $WG_NAME link del dev $WG_NAME
    }
    try {
        ip netns del $WG_NAME
    }
    try {
        ip link del $WG_NAME
    }
    try {
        ip link delete host0
    }
    print $"Namespace ($WG_NAME) is down"
}

def "all up" [private_key_file: path] {
    nordvpn down
    shared down

    let server = get-servers | shuffle | get 0
    let public_key = (
        $server.technologies 
            | where identifier == "wireguard_udp" 
            | get 0.metadata 
            | where name == "public_key" 
            | get 0.value
    )
    let hostname = $server | get hostname

    ip netns add $WG_NAME

    # Loopback interface up
    ip -n $WG_NAME link set lo up

    ip link add $WG_NAME type wireguard

    print $"Connecting to ($hostname) with public key ($public_key)"

    # Connect now to allow dns to resolve as normal
    (
        wg set $WG_NAME 
            private-key $private_key_file
            peer $public_key
            endpoint $"($hostname):51820" 
            allowed-ips "0.0.0.0/0,::0/0"
    )

    print "Connected"
    ip link set $WG_NAME netns $WG_NAME

    ip -n $WG_NAME addr add $WG_IP dev $WG_NAME
    ip -n $WG_NAME link set mtu 1420 up dev $WG_NAME

    ip -j -n $WG_NAME route add default dev $WG_NAME

    print $"Namespace ($WG_NAME) is up, creating shared"

    ip netns add shared

    ip -n shared link set lo up

    ip link add host0 type veth peer name shared0
    ip link set shared0 netns shared
    ip addr add 10.200.0.1/24 dev host0

    ip netns exec shared ip addr add 10.200.0.2/24 dev shared0
    ip link set host0 up
    ip netns exec shared ip link set shared0 up

    ip link add host2 type veth peer name vpn2
    ip link set vpn2 netns $WG_NAME
    ip addr add 10.224.0.1/24 dev host2
    ip netns exec $WG_NAME ip addr add 10.224.0.2/24 dev vpn2 

    ip link set host2 up
    ip netns exec $WG_NAME ip link set vpn2 up

    ip -n shared link add shared1 type veth peer name vpn1
    ip -n shared link set vpn1 netns $WG_NAME
    ip netns exec shared ip addr add 10.222.0.1/24 dev shared1 
    ip netns exec $WG_NAME ip addr add 10.222.0.2/24 dev vpn1 

    ip netns exec shared ip link set shared1 up
    ip netns exec $WG_NAME ip link set vpn1 up

    ip netns exec $WG_NAME iptables -P FORWARD DROP
    ip netns exec $WG_NAME iptables -A INPUT -m state --state INVALID -j DROP
    ip netns exec $WG_NAME iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
    ip netns exec $WG_NAME iptables -A FORWARD -i vpn1 -o nordvpn -j ACCEPT
    ip netns exec $WG_NAME iptables -A FORWARD -i nordvpn -o vpn1 -j ACCEPT
    ip netns exec $WG_NAME iptables -A FORWARD -i vpn2 -o nordvpn -j ACCEPT
    ip netns exec $WG_NAME iptables -A FORWARD -i nordvpn -o vpn2 -j ACCEPT
    ip netns exec $WG_NAME iptables -t nat -A POSTROUTING -s 10.222.0.0/24 -o nordvpn -j MASQUERADE
    ip netns exec $WG_NAME iptables -t nat -A POSTROUTING -s 10.224.0.0/24 -o nordvpn -j MASQUERADE

    # Wifi through VPN
    ip netns exec shared ip route add default via 10.222.0.2
    # Netbird through host
    ip netns exec shared ip route add 100.114.0.0/16 via 10.200.0.1
}

def "main up" [private_key_file: path] {
    all up $private_key_file
}

def "main" [] {
    error make { msg: "Run either up or down!" }
}
