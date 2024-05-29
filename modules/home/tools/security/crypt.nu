def tomb-env [code: closure] {
    with-env {
        PATH: ($env.PATH | prepend @NIX_PATH_PREPEND@ | append @NIX_PATH_APPEND@)
    } {
        do $code
    }
}

def mountpoint [] {
    tomb-env {
        let cmd = (which tomb | get path.0 | readlink $in)
        let uniq_mounts = (do { 
            sudo --preserve-env $cmd list 
        } | complete | get stderr | split row (char newline) | each {
                |x| $x | parse -r `^tomb\s+\.\s+\[(?P<tomb>\w+)\]` 
            } | filter {|x| ($x | length) != 0} | each { 
                |x| $x | get tomb.0 
            } | uniq)
        return ([ 'all' ] | append $uniq_mounts)
    }
}

# Wrapper for tomb close (with autocomplete!)
export def "close" [
    tomb?: string@mountpoint # Tomb to close
] {
    tomb-env {
        let cmd = (which tomb | get path.0 | readlink $in)
        if ($tomb | is-empty) {
            sudo --preserve-env $cmd close
        } else {
            sudo --preserve-env $cmd close $tomb
        }
    }
}

# Forcefully close all tombs
# This is sudo, so it *will* succeed
export def "slam" [] {
    tomb-env {
        let cmd = (which tomb | get path.0 | readlink $in)
        sudo --preserve-env $cmd slam
    }
}

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
    tomb-env {
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
        # This protects files within the tomb
        chmod 700 $tomb_mount
        let cmd = (which tomb | get path.0 | readlink $in)
        if ($no_force) {
            ^$cmd open -k $key_location $tomb_location $tomb_mount -o ...$options
        } else {
            ^$cmd open -k $key_location $tomb_location $tomb_mount -f -o ...$options
        }
    }
}

