def crypt-env [code: closure] {
    with-env {
        PATH: ($env.PATH | prepend @NIX_PATH_PREPEND@ | append @NIX_PATH_APPEND@)
    } {
        do $code
    }
}

def pub-identities [] {
    (ls /mnt/tomb/tombs/age/*.pub | get name )
}

export def "passphrase" [num: int = 3] {
    crypt-env {
        diceware --no-caps -d "-" -n $num
    }
}

export def "send" [file: path, --code-length: int = 3, --force-relay] {
    crypt-env {
        print $"Sending ($file)"
        let code = passphrase $code_length
        print $"Code: ($code)"
        if $force_relay {
            wormhole-rs send $file --code $code --force-relay | print
        } else {
            wormhole-rs send $file --code $code | print
        }
    }
}

export def "receive" [code?: string, --force-relay, --out-dir: path] {
    let code = if ($code | is-empty) {
        let val = $in
        if ($val | is-empty) {
            input "Enter code: " | str trim
        } else {
            $val
        }
    } else {
        $code
    }
    crypt-env {
        let dir = if ($out_dir | is-empty) {
            (mktemp -d -t wormhole-receive.XXXXXX)
        } else {
            $out_dir
        }
        print $"Receiving in ($dir)"
        if ((ls -a $dir | length) > 0) {
            error make {
                msg: $"The out dir needs to be empty to find received files! \(($dir))"
            }
        }
        (if $force_relay {
            wormhole-rs receive $code --out-dir $dir --force-relay
        } else {
            wormhole-rs receive $code --out-dir $dir
        })
        return (ls -a $dir | get 0 | each {|x| $x.name | path expand})
    }
}

export def "send-text" [text?: string, --code-length: int = 3, --force-relay] {
    let text = if ($text | is-empty) {
        $in
    } else {
        $text
    }
    let file = (mktemp -t wormhole-text.XXXXXX.txt)
    $in | save -f $file

    if $force_relay {
        send $file --code-length $code_length --force-relay
    } else {
        send $file --code-length $code_length
    }

    rm -p $file
}

export def "receive-text" [code?: string, --force-relay] {
    let code = if ($code | is-empty) {
        let val = $in
        if ($val | is-empty) {
            input "Enter code: " | str trim
        } else {
            $val
        }
    } else {
        $code
    }

    let dir = (mktemp -d -t wormhole-receive.XXXXXX)

    let file = if ($force_relay) {
        receive $code --out-dir $dir
    } else {
        receive $code --force-relay --out-dir $dir
    }
    let content = open -r $file
    rm -rp $dir
    return $content
}

export def "receive-encrypted" [--identity: path, --super-paranoid: path@pub-identities] {
    if ($super_paranoid | is-not-empty) {
        if ($identity | is-not-empty) {
            error make {
                msg: "If super-paranoid, there can't be an identity!"
            }
        }

        let keydir = (mktemp -d -t key.XXXXXX)
        let key = $keydir | path join "key.age"
        let encpubkey = $keydir | path join "key.pub.age.enc"

        let pubkey = do { age-keygen -o $key } | complete | get stderr | split row ':' | get 1 | str trim
        $pubkey | save -f ($keydir | path join "key.pub.age")

        $pubkey | age --recipients-file $super_paranoid --output $encpubkey

        send $encpubkey
        print ""
        print ""
        print $"Check that these hashes are the same: ($pubkey | hash sha256)"
        input "Hit enter when ready"

        let code = input "Enter code: " | str trim
        let file = receive $code
        let decdir = mktemp -t -d decrypted.XXXXXX
        let decfile = $decdir | path join ($file | path basename)
        age --decrypt --identity $key --output $decfile $file
        rm -rp $keydir
        return $decfile
    } else if ($identity | is-empty) {
        let keydir = (mktemp -d -t key.XXXXXX)
        let key = $keydir | path join "key.age"

        let pubkey = do { age-keygen -o $key } | complete | get stderr | split row ':' | get 1 | str trim
        $pubkey | save -f ($keydir | path join "key.pub.age")

        $pubkey | send-text
        print ""
        print ""
        print $"Check that these hashes are the same: ($pubkey | hash sha256)"
        input "Hit enter when ready"

        let code = input "Enter code: " | str trim
        let file = receive $code
        let decdir = mktemp -t -d decrypted.XXXXXX
        let decfile = $decdir | path join ($file | path basename)
        age --decrypt --identity $key --output $decfile $file
        rm -rp $keydir
        rm -p $file
        return $decfile
    } else {
        let code = input "Enter code: " | str trim
        let file = receive $code
        print $"Received ($file)"
        let decdir = mktemp -t -d decrypted.XXXXXX
        let decfile = $decdir | path join ($file | path basename)
        age --decrypt --identity $identity --output $decfile $file
        rm -p $file
        return $decfile
    }
}

export def "send-encrypted" [--identity: path@pub-identities, --super-paranoid: path] {
    let tosend = $in
    if ($super_paranoid | is-not-empty) {
        # This is a lot like normal no identity, but the keys are encrypted with a known keypair
        if ($identity | is-not-empty) {
            error make {
                msg: "If super-paranoid, there can't be an identity!"
            }
        }
        let code = input "Enter code: " | str trim
        let file = receive $code

        let pubkey = age --decrypt --identity $super_paranoid $file

        print ""
        print ""
        print $"Check that these hashes are the same: ($pubkey | hash sha256)"
        input "Hit enter when ready"

        # Pubkey sent successfully, now send the encrypted message
        let encfile = (mktemp -t encrypted-text.XXXXXX)
        $tosend | age --recipient $pubkey --output $encfile

        send $encfile
        rm -p $encfile
    } else if ($identity | is-empty) {
        let code = input "Enter code: " | str trim
        let pubkey = receive-text $code
        print ""
        print ""
        print $"Check that these hashes are the same: ($pubkey | hash sha256)"
        input "Hit enter when ready"

        # Pubkey sent successfully, now send the encrypted message
        let encfile = (mktemp -t encrypted-text.XXXXXX)
        $tosend | age --recipient $pubkey --output $encfile

        send $encfile
        rm -p $encfile
    } else {
        # Simplest of the options, known identity so just encrypt and yolo
        let encfile = (mktemp -t encrypted-text.XXXXXX)
        $tosend | age --recipients-file $identity --output $encfile

        send $encfile
        rm -p $encfile
    }

}

export def "receive-text-encrypted" [--identity: path, --super-paranoid: path@pub-identities] {
    let file = receive-encrypted --identity $identity --super-paranoid $super_paranoid
    let content = open -r $file
    rm -p $file
    return $content
}

export def "encrypt" [
    recipient: path@pub-identities,
] {
    $in | age --recipients-file $recipient
}

export def "decrypt" [
    identity: path,
] {
    $in | age --decrypt --identity $identity
}

def mountpoint [] {
    crypt-env {
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
    crypt-env {
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
    crypt-env {
        let cmd = (which tomb | get path.0 | readlink $in)
        sudo --preserve-env $cmd slam
    }
}

def discovered-tombs [] {
    (ls /mnt/tomb/tombs/*.tomb | each {|x| $x.name | path basename })
}

def discovered-keys [] {
    (ls /mnt/tomb/tombs/*.key | each {|x| $x.name | path basename })
}

# Open up a tomb use predefined standards
export def "unseal" [
    key?: string@discovered-keys, # The key name in $TOMBS_LOCATION (autocomplete uses default tomb location)
    tomb?: string@discovered-tombs, # The tomb name in $TOMBS_LOCATION (autocomplete uses default tomb location)
    --tomb-path(-T): path, # Direct path to tomb
    --key-path(-K): path, # Direct path to tomb key
    --tombs-location(-L): path = '/mnt/tomb/tombs', # The location to search for tombs and keys
    --mnt-point(-M): path # The mount point for the tomb, defaults to $TOMBS_LOCATION/../<name>
    --no-force, # Don't open if swap is on
    --options(-o): list<string> = [ "rw" "nodev" "noatime" "compress=zstd:5" ] # Options to mount with
] {
    crypt-env {
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

