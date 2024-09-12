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

# Generates a passphrase meant for a one-time code
# Strings together a few random words with `-`
export def "passphrase" [
    num: int = 3             # number of words in passphrase
] none -> string {
    crypt-env {
        diceware --no-caps -d "-" -n $num
    }
}

# Send a file or data through wormhole
#
# You can pipe in data, but should then specify --ext to declare
# what type you are sending
export def "send" [
    file?: path,             # File to send
    --code-length: int = 3,  # Length of password
    --force-relay            # Force relay with wormhole (doesn't share your IP with peer)
    --ext: string = "txt",   # Sets file extension type. File must not be declared.
] any -> none {
    let piped = $in
    crypt-env {
        mut tmpd = false;
        mut realfile = $file
        if ($file | is-empty) {
            $tmpd = true;
            $realfile = (mktemp -t $"wormhole.XXXXXX.($ext)")
            if ($piped | is-empty) {
                error make {
                    msg: "Input file and piped data cannot both be empty!"
                }
            }
            $piped | save -f $realfile
        }
        print $"Sending ($file)"
        let code = passphrase $code_length
        print $"Code: ($code)"
        if $force_relay {
            wormhole-rs send $realfile --code $code --force-relay | print
        } else {
            wormhole-rs send $realfile --code $code | print
        }
    }
}

# Receive a file from wormhole
#
# The output file will be in a temp directory. Returns the received file unless discard is specified.
export def "receive" [
    code?: string,     # Wormhole code (will ask for input if not provided)
    --force-relay,     # Force relay with wormhole (doesn't share your IP with peer)
    --out-dir: path    # output directory for the file
    --discard(-d)      # open file and return that instead of the got file
] string? string? -> path? {
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
        let file = (ls -a $dir | get 0 | each {|x| $x.name | path expand})
        if $discard {
            let content = open -r $file
            rm -p $file
            return $content
        } else {
            return $file
        }
    }
}

# Recieve encrypted data through wormhole.
#
# Specify your private identity if the payload has been encrypted on it
#
# Specify senders public identity to create a key pair and encrypt it first
#
# Specify no identity to create keys and do an initial key exchange
export def "receive-encrypted" [
    --identity(-i): path,                                  # your private key to decrypt data
    --super-paranoid-sender-pub(-s): path@pub-identities,  # sender's public key for super paranoid mode
    --discard(-d)                                          # Return file contents and delete the file
] {
    if ($super_paranoid_sender_pub | is-not-empty) {
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

        $pubkey | age --recipients-file $super_paranoid_sender_pub --output $encpubkey

        send $encpubkey
        print ""
        print ""
        print $"Check that these hashes are the same: ($pubkey | hash sha256)"
        input "Hit enter when ready"

        let code = input "Enter code: " | str trim
        let file = receive $code
        let decdir = mktemp -t -d decrypted.XXXXXX
        let decfile = $decdir | path join ($file | path basename | str replace "encrypted" "decrypted")
        let decrypted = age --decrypt --identity $key $file
        rm -rp $keydir
        rm -p $file
        if $discard {
            return $decrypted
        }
        $decrypted | save -f $decfile
        return $decfile
    } else if ($identity | is-empty) {
        let keydir = (mktemp -d -t key.XXXXXX)
        let key = $keydir | path join "key.age"

        let pubkey = do { age-keygen -o $key } | complete | get stderr | split row ':' | get 1 | str trim
        $pubkey | save -f ($keydir | path join "key.pub.age")

        $pubkey | send
        print ""
        print ""
        print $"Check that these hashes are the same: ($pubkey | hash sha256)"
        input "Hit enter when ready"

        let code = input "Enter code: " | str trim
        let file = receive $code
        let decdir = mktemp -t -d decrypted.XXXXXX
        let decfile = $decdir | path join ($file | path basename | str replace "encrypted" "decrypted")
        let decrypted = age --decrypt --identity $key $file
        rm -rp $keydir
        rm -p $file
        if $discard {
            return $decrypted
        }
        $decrypted | save -f $decfile
        return $decfile
    } else {
        let code = input "Enter code: " | str trim
        let file = receive $code
        print $"Received ($file)"
        let decdir = mktemp -t -d decrypted.XXXXXX
        let decfile = $decdir | path join ($file | path basename | str replace "encrypted" "decrypted")
        let decrypted = age --decrypt --identity $identity $file
        if $discard {
            return $decrypted
        }
        rm -p $file
        $decrypted | save -f $decfile
        return $decfile
    }
}

# Send encrypted data through wormhole. Can either be a specified path or piped data.
#
# Specify recipient to encrypt with their public key
#
# Specify your private key for super paranoid to decrypt received key
#
# Specify no encrypt data with received public key from wormhole
export def "send-encrypted" [
    file?: path,                         # File to send. Will use piped in data if not specified
    --recipient: path@pub-identities,    # Public identity for the recipient
    --super-paranoid-priv-key: path,     # Private identity for super paranoid mode
    --ext: string = "txt"                # extension for file
] any -> none {
    let tosend = if ($file | is-empty) {
        if ($in | is-empty) {
            error make {
                msg: "No input and no file specified"
            }
        }
        $in
    } else {
        $file
    }
    if ($super_paranoid_priv_key | is-not-empty) {
        # This is a lot like normal no identity, but the keys are encrypted with a known keypair
        if ($recipient | is-not-empty) {
            error make {
                msg: "If super-paranoid, there can't be an identity!"
            }
        }
        let code = input "Enter code: " | str trim
        let file = receive $code

        let pubkey = age --decrypt --recipient $super_paranoid_priv_key $file

        print ""
        print ""
        print $"Check that these hashes are the same: ($pubkey | hash sha256)"
        input "Hit enter when ready"

        # Pubkey sent successfully, now send the encrypted message
        let encfile = (mktemp -t $"encrypted.XXXXXX.($ext)")
        $tosend | age --recipient $pubkey --output $encfile

        send $encfile
        rm -p $encfile
    } else if ($recipient | is-empty) {
        let code = input "Enter code: " | str trim
        let pubkey = receive -d $code
        print ""
        print ""
        print $"Check that these hashes are the same: ($pubkey | hash sha256)"
        input "Hit enter when ready"

        # Pubkey sent successfully, now send the encrypted message
        let encfile = (mktemp -t $"encrypted.XXXXXX.($ext)")
        $tosend | age --recipient $pubkey --output $encfile

        send $encfile
        rm -p $encfile
    } else {
        # Simplest of the options, known identity so just encrypt and yolo
        let encfile = (mktemp -t $"encrypted.XXXXXX.($ext)")
        $tosend | age --recipients-file $recipient --output $encfile

        send $encfile
        rm -p $encfile
    }

}

# Helper to quickly encrypt piped in data with age
export def "encrypt" [
    recipient: path@pub-identities, # Recipient's public key
] any -> any {
    $in | age --recipients-file $recipient
}

# Helper to quickly encrypt piped in data with age
export def "decrypt" [
    identity: path, # Your private key
] any -> any {
    $in | age --decrypt --identity $identity
}

# Helper to quickly encrypt piped in data with tlock
export def "time-encrypt" [
    time: string
] {
    $in | tle -e -D $time
}

# Helper to quickly deecrypt piped in data with tlock
export def "time-decrypt" [] {
    $in | tle -d 
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

