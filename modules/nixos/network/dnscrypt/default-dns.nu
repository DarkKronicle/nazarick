#!/usr/bin/env nu

# A script to switch to default DNS servers instead of local DNS servers.
# This is important if you need DNS resolving for the current network connections
# Captive portals are the main use
def main [] {
    plugin use explore

    let readonly = ls -l /etc/resolv.conf | get 0.readonly
    let connections = nmcli con | split row (char newline)

    let name_length = $connections | get 0 | parse --regex '(NAME.+)UUID' | get 0.capture0 | str length
    let uuid_length = $connections | get 0 | parse --regex '(NAME.+)TYPE' | get 0.capture0 | str length
    let type_length = $connections | get 0 | parse --regex '(NAME.+)DEVICE' | get 0.capture0 | str length

    let names = $connections | skip 1 | str substring 0..($name_length - 1) | str trim
    let uuids = $connections | skip 1 | str substring $name_length..($uuid_length - 1) | str trim
    let types = $connections | skip 1 | str substring $uuid_length..($type_length - 1) | str trim
    let devices = $connections | skip 1 | str substring $type_length.. | str trim

    mut connections = []

    for i in 0..(($devices | length) - 1) {
        $connections = ($connections | append { name: ($names | get $i), uuid: ($uuids | get $i), type: ($types | get $i), device: ($devices | get $i)})
    }

    let connections = $connections

    let chosen = ($connections | nu_plugin_explore).name
    print $"Using dns servers for ($chosen)"
    let info = nmcli con show $chosen | split row (char newline)
    # Find all the dns servers, format them nicely, and get the value
    let dns = $info | find --regex "^IP4.DNS" | append ($info | find "IP6.DNS") | ansi strip | each {|x| ($x | split row " " | skip 1 | str join " " | str trim)}

    if ($dns | length) == 0 {
        error make { msg: "No DNS servers found on NetworkManager configuration" }
    }

    print $"DNS servers: ($dns)"

    let backup_file = mktemp -t resolv.conf-XXXXXX
    let new_file = mktemp -t resolv.conf-XXXXXX

    $dns | each {|x| $"nameserver ($x)"} | str join (char newline) | save -f $new_file

    print $"Backup at ($backup_file), file to paste ($new_file)"
    sudo cp /etc/resolv.conf $backup_file 

    if $readonly {
        sudo chattr -i /etc/resolv.conf
    }

    sudo cp $new_file /etc/resolv.conf 

    print "DNS server has been changed successfully. Press <enter> when operation should be undone."
    print "Note: if using a web browser, you may need to disable custom DNS configuration and also restart the browser"
    # Nothing here is needed, this will just wait for user interaction
    input
    print "Reverting changes..."

    sudo cp $backup_file /etc/resolv.conf 

    # Make immutable again
    if $readonly {
      sudo chattr +i /etc/resolv.conf
    }

    rm -fp $backup_file
    rm -fp $new_file
    print "Done!"
}
