# Example

# #
# # Menu entries
# # 
# menuentry 'NixOS 24.05.20240512.2057814 Installer '  --class installer {
#  # Fallback to UEFI console for boot, efifb sometimes has difficulties.
#  # terminal_output console
 
  # linux /boot/bzImage ${isoboot} init=/nix/store/82zmrbi0adij4yw1sv7x1b061bbhjj87-nixos-system-recovery-24.05.20240512.2057814/init  root=LABEL=nixos-24.05-x86_64 boot.shell_on_fail nohibernate loglevel=4 
# initrd /boot/initrd
# }

def open_safely [] {
    let $location = $in
    if ($location | path exists) {
        return (open $location)
    } else {
        return ""
    }
}

def make_entry [root_dir: path, image: path] {
    let init = ([$root_dir 'init'] | path join | path expand);
    let params = ([$root_dir 'kernel-params'] | path join | open | str trim);
    mut name = ([$root_dir 'configuration-name'] | path join | open_safely);
    if ($name | is-empty) {
        $name = ($root_dir | path basename);
        $name = $"NixOS - ($name)"
    }
    let entry = $"
    menuentry '($name)' --class installer {
        terminal_output console
        linux ($image) ${isoboot} init=($init) ($params)
        initrd /boot/initrd
    }
    "
    return $entry
}

# We just need to have our own init
def main [grub_cfg: path, toplevel_path: path, image: path] {
    mut entries = [];
    for $specialisation_path in (glob $"($toplevel_path)/specialisation/*" | sort) {
        $entries = ($entries | append (make_entry $specialisation_path $image))
    }
    let new_entries = ($entries | str join (char newline))
    let split = "
    #
    # Menu entries
    #
    " | str trim | str replace --all '    ' ''
    chmod +w $grub_cfg
    (open $grub_cfg | split row $split | insert 1 $new_entries) | str join (char newline) | save -f $grub_cfg
    chmod -w $grub_cfg
}
