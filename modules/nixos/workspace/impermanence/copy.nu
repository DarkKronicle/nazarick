def update_file [ persist: path, last_home: path, file: path] {
    if ($file | str starts-with '/home') {
        let homeless_path = ($file | str substring 6..)
        # File permissions need to be good
        # home directories: `darkkronicle, users, 0755` 
        # root directories: `root, root, 0755`
        mut path_dir = ($file | path dirname)
        mut parents = [ $path_dir ] 
        while ($path_dir != "/home/darkkronicle")  { 
          $path_dir = ($path_dir | path dirname)
          $parents = [ $path_dir ...$parents] 
        }
        for parent in $parents {
          if (not ($parent | path exists)) {
            ^mkdir --mode 0755 $parent
            chown darkkronicle:users $parent
          }
          let persist_path_join = ([$persist ($parent | str substring 1..)] | path join)
          if (not ($persist_path_join | path exists)) {
            ^mkdir --mode 0755 $persist_path_join
            chown darkkronicle:users $persist_path_join
          }
        }
        let persist_spot = ([ $persist ( $file | str substring 1..) ] | path join)
        let last_spot = ([ $last_home $homeless_path ] | path join)
        # If last spot exists and it has *some* data. If this has problems can probably do == 0B;
        # The main reason for this is that they technically *do* exist if they were on a previous
        # impermanence config. This way it now will only overwrite if it has something.
        print $"Checking ($last_spot)"
        if (($last_spot | path exists) and ((ls -l $last_spot | get size.0) > 2B)) {
            print $"Copying from ($last_spot) -> ($persist_spot)"
            # -u makes it so it takes the newer modified file
            cp -f -u $last_spot $persist_spot
        }
        print $"Checking existing"
        if ($file | path exists) {
            print $"Attempting to update persist location ($persist_spot)"
            cp -f -u $file $persist_spot
        }
        print $"Checking ($persist_spot)"
        if ($persist_spot | path exists) {
            print $"Copying from ($persist_spot) -> ($file)"
            cp -f $persist_spot $file

            chown $"--reference=($persist_spot)" $file
            chmod $"--reference=($persist_spot)" $file
        }
    }
}


def main [...transient_paths: path] {
    let btrfs_mount: path = (mktemp -d --suffix .btrfs-mount)
    let persist: path = '/persist'
    let last_home = ([ $btrfs_mount 'last_home' ] | path join)

    mount /dev/mapper/cryptroot $btrfs_mount
    try {
        for path in $transient_paths {
            update_file ([ $persist 'transient' ] | path join) $last_home $path
        }
    } catch {|e| 
        print $e
    }
    umount $btrfs_mount
}
