export def "open" [
    key?: string, # The key name in $TOMBS_LOCATION
    tomb?: string, # The tomb name in $TOMBS_LOCATION
    --tomb-path(-T): path, # Direct path to tomb
    --key-path(-K): path, # Direct path to tomb key
    --tombs-location(-L): path = '/mnt/tomb/tombs', # The location to search for tombs and keys
    --mnt-point(-M): path # The mount point for the tomb, defaults to $TOMBS_LOCATION/../<name>
    --no-force, # Don't open if swap is on
    --options(-o): list<string> = [ "rw" "nodev" "noatime" "compress=zstd:5" ] # Options to mount with
] {
    with-env {
        PATH: ($env.PATH | prepend @NIX_PATH_PREPEND@ | append @NIX_PATH_APPEND@)
    } {
        let key_location = if ($key | is-not-empty) {
            glob $"([$tombs_location $key] | path join)*.key" | get 0
        } else {
            if ($key_path | is-empty) {
                error make { msg: "Key path cannot be empty if key is" }
            }
            $key_path
        }
        let tomb_location = if ($tomb | is-not-empty) {
            glob $"([$tombs_location $tomb] | path join)*.tomb" | get 0
        } else {
            if ($tomb_path | is-empty) {
                error make { msg: "Tomb path cannot be empty if tomb is" }
            }
            $tomb_path
        }
        if (not ($key_location | path exists)) {
            error make {
                msg: $"No key found at ($key_location)"
            }
        }
        if (not ($tomb_location | path exists)) {
            error make {
                msg: $"No tomb found at ($tomb_location)"
            }
        }
        let tomb_name = ($tomb_location | path parse | get stem)
        let tomb_mount = if ($mnt_point | is-empty) {
            [($tombs_location | path dirname) $tomb_name ] | path join
        } else {
            $mnt_point
        }
        mkdir $tomb_mount
        if ($no_force) {
            tomb open -k $key_location $tomb_location $tomb_mount -o ...$options
        } else {
            tomb open -k $key_location $tomb_location $tomb_mount -f -o ...$options
        }
    }
}

