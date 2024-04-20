def update_file [ persist: path,  file: path] {
    if ($file | str starts-with '/home') {
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
        # If last spot exists and it has *some* data. If this has problems can probably do == 0B;
        # The main reason for this is that they technically *do* exist if they were on a previous
        # impermanence config. This way it now will only overwrite if it has something.
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
    let persist: path = '/persist'
    try {
        for path in $transient_paths {
            update_file ([ $persist 'transient' ] | path join) $path
        }
    } catch {|e| 
        print $e
    }
}

