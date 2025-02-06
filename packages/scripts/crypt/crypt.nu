def crypt-env [code: closure] {
    with-env {
        PATH: ($env.PATH | prepend @NIX_PATH_PREPEND@ | append @NIX_PATH_APPEND@)
    } {
        do $code
    }
}

def age-key-dir []: nothing -> path {
    let dir = $env.CRYPT_AGE_DIR?
    if ($dir | is-empty) {
        return "/mnt/tomb/tombs/age"
    }
    return $dir
}

def tomb-dir []: nothing -> path {
    let dir = $env.CRYPT_TOMB_DIR?
    if ($dir | is-empty) {
        return "/mnt/tomb/tombs"
    } 
    # Expand to get rid of trailing /
    return ($dir | path expand)
}

def pub-age-identities [] {
    glob $"(age-key-dir)/age-*.pub" | append (glob age-*.pub) | uniq
}

def private-age-identities [] {
    glob $"(tomb-dir)/age-*" --exclude [ '*.*' ] | append (glob *) | uniq
}

# Generates a passphrase meant for a one-time code
# Strings together a few random words with `-`
export def "passphrase" [
    num: int = 3             # number of words in passphrase
]: nothing -> string {
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
    --force-relay(-R)        # Force relay with wormhole (doesn't share your IP with peer)
    --force-direct(-D)       # Force direct with wormhole
    --ext: string = "txt",   # Sets file extension type. File must not be declared.
]: any -> nothing {
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
        if (force_relay and $force_direct) {
            error make { msg: "Cannot force relay and direct!" }
        }
        if $force_relay {
            wormhole-rs send $realfile --code $code --force-relay | print
        } else if $force_direct {
            wormhole-rs send $realfile --code $code --force-direct | print
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
    --force-relay(-R), # Force relay with wormhole (doesn't share your IP with peer)
    --force-direct(-D),# Force direct with wormhole
    --out-dir: path    # output directory for the file
    --discard(-d)      # open file and return that instead of the got file
]: string -> path {
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
        if ($force_relay and $force_direct) {
            error make { msg: "Cannot force relay and direct!" }
        }
        if $force_relay {
            wormhole-rs receive $code --out-dir $dir --force-relay
        } else if ($force_direct) {
            wormhole-rs receive $code --out-dir $dir --force-direct
        } else {
            wormhole-rs receive $code --out-dir $dir
        }
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
    --identity(-i): path@private-age-identities,               # your private key to decrypt data
    --super-paranoid-sender-pub(-s): path@pub-age-identities,  # sender's public key for super paranoid mode
    --discard(-d),                                             # Return file contents and delete the file
    --force-direct(-D),
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

        let file = if ($force_direct) {
            send $encpubkey --force-direct
        } else {
            send $encpubkey
        }
        print ""
        print ""
        print $"Check that these hashes are the same: ($pubkey | hash sha256)"
        input "Hit enter when ready"

        let code = input "Enter code: " | str trim
        let file = if ($force_direct) {
            receive $code --force-direct
        } else {
            receive $code
        }
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

        if ($force_direct) {
            $pubkey | send --force-direct
        } else {
            $pubkey | send
        }
        print ""
        print ""
        print $"Check that these hashes are the same: ($pubkey | hash sha256)"
        input "Hit enter when ready"

        let code = input "Enter code: " | str trim
        let file = if ($force_direct) {
            receive $code --force-direct
        } else {
            receive $code
        }
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
        let file = if ($force_direct) {
            receive $code --force-direct
        } else {
            receive $code
        }
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
    file?: path,                             # File to send. Will use piped in data if not specified
    --recipient: path@pub-age-identities,    # Public identity for the recipient
    --super-paranoid-priv-key: path@private-age-identities,         # Private identity for super paranoid mode
    --ext: string = "txt"                    # extension for file
    --force-direct(-D)
]: any -> nothing {
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
        let file = if ($force_direct) {
            receive $code --force-direct
        } else {
            receive $code
        }

        let pubkey = age --decrypt --recipient $super_paranoid_priv_key $file

        print ""
        print ""
        print $"Check that these hashes are the same: ($pubkey | hash sha256)"
        input "Hit enter when ready"

        # Pubkey sent successfully, now send the encrypted message
        let encfile = (mktemp -t $"encrypted.XXXXXX.($ext)")
        $tosend | age --recipient $pubkey --output $encfile

        if ($force_direct) {
            send $encfile --force-direct
        } else {
            send $encfile
        }
        rm -p $encfile
    } else if ($recipient | is-empty) {
        let code = input "Enter code: " | str trim
        let pubkey = if ($force_direct) {
            receive -d $code --force-direct
        } else {
            receive -d $code
        }
        print ""
        print ""
        print $"Check that these hashes are the same: ($pubkey | hash sha256)"
        input "Hit enter when ready"

        # Pubkey sent successfully, now send the encrypted message
        let encfile = (mktemp -t $"encrypted.XXXXXX.($ext)")
        $tosend | age --recipient $pubkey --output $encfile

        if ($force_direct) {
            send $encfile --force-direct
        } else {
            send $encfile
        }
        rm -p $encfile
    } else {
        # Simplest of the options, known identity so just encrypt and yolo
        let encfile = (mktemp -t $"encrypted.XXXXXX.($ext)")
        $tosend | age --recipients-file $recipient --output $encfile

        if ($force_direct) {
            send $encfile --force-direct
        } else {
            send $encfile
        }
        rm -p $encfile
    }

}

# Helper to quickly encrypt piped in data with age
export def "encrypt" [
    recipient: path@pub-age-identities, # Recipient's public key
    --armor(-a) # PEM encode
]: any -> any {
    if $armor {
        $in | age -a --recipients-file $recipient
    } else {
        $in | age --recipients-file $recipient
    }
}

# Helper to quickly encrypt piped in data with age
export def "decrypt" [
    identity: path@private-age-identities # Your private key
]: any -> any {
    $in | age --decrypt --identity $identity
}

# Helper to quickly encrypt piped in data with tlock
export def "time-encrypt" [
    time: any,              # Time to unencrypt (either datetime or duration)
    --armor(-a)             # PEM encode
] {

    let time = (if (($time | describe) == "date") {
        ($time - (date now))
    } else if (($time | describe) == "string") {
        (($time | into datetime) - (date now))
    } else {
        $time
    })
    print $"Available ($time + (date now))"
    let inside = $in
    let secs = $time | into duration | format duration sec | split row " " | get 0 | into int
    if $armor {
        $inside | tle -a -e -D $"($secs)s"
    } else {
        $inside | tle -e -D $"($secs)s"
    }
}

# Helper to quickly deecrypt piped in data with tlock
export def "time-decrypt" [] {
    $in | tle -d 
}

def mountpoint [] {
    crypt-env {
        # let cmd = (which tomb | get path.0 | readlink $in)
        let uniq_mounts = (do { 
            sudo --preserve-env tomb list 
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
        # let cmd = (which tomb | get path.0 | readlink $in)
        if ($tomb | is-empty) {
            sudo --preserve-env tomb close
        } else {
            sudo --preserve-env tomb close $tomb
        }
    }
}

# Forcefully close all tombs
# This is sudo, so it *will* succeed
export def "slam" [] {
    crypt-env {
        # let cmd = (which tomb | get path.0 | readlink $in)
        sudo --preserve-env tomb slam
    }
}

def discovered-tombs [] {
    glob $"(tomb-dir)/*.tomb" | append (glob *.tomb) | uniq
}

def discovered-keys [] {
    glob $"(tomb-dir)/*.key" | append (glob *.key) | uniq
}

# Open up a tomb use predefined standards
export def "unseal" [
    key: path@discovered-keys, # The key name in $TOMBS_LOCATION (autocomplete uses default tomb location)
    tomb: path@discovered-tombs, # The tomb name in $TOMBS_LOCATION (autocomplete uses default tomb location)
    --tombs-location(-L): path = '/mnt/tomb/tombs', # The location to search for tombs and keys
    --mnt-point(-M): path # The mount point for the tomb, defaults to $TOMBS_LOCATION/../<name>
    --no-force, # Don't open if swap is on
    --options(-o): list<string> = [ "rw" "nodev" "noatime" "compress=zstd:5" ] # Options to mount with
] {
    crypt-env {
        let key_location = $key
        let tomb_location = $tomb
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
        # let cmd = (which tomb | get path.0 | readlink $in)
        if ($no_force) {
            tomb open -k $key_location $tomb_location $tomb_mount -o ...$options
        } else {
            tomb open -k $key_location $tomb_location $tomb_mount -f -o ...$options
        }
    }
}


# Referenced from
# https://github.com/makew0rld/rfcts
# https://github.com/ysimonx/timestamping-server-with-digicert/

export def "timestamp" [--server(-s): string = "http://timestamp.digicert.com", --discard(-d)] {
    let input = $in
    crypt-env {
        let folder = mktemp -t -d "timestamp.XXXXXX"
        cd $folder
        let data = do {
            $input | openssl ts -query -data /dev/stdin -sha512 -cert -out tmp.tsq
        } | complete 
        if ($data.exit_code != 0) {
            error make { msg: "Could not create verification!" }
        }
        curl --no-progress-meter -H "Content-Type: application/timestamp-query" --data-binary '@tmp.tsq' $server | save tmp.tsr
        let data = do {
            openssl ts -reply -in tmp.tsr -text
        } | complete
        if ($data.exit_code != 0) {
            error make { msg: "Could not print information!" }
        }
        print $data.stdout
        if ($discard) {
            let data = open tmp.tsq | collect
            cd -
            rm -rp $folder
            return $data
        }
        print $"(char newline)Testing verification..."
        let timestamp = $input | timestamp-verify tmp.tsr

        return {timestamp: $timestamp, file: ([$folder tmp.tsr] | path join)}
    }
}

export def "timestamp-verify" [tsr: path] {
    let input = $in
    crypt-env {
        let data = do {
            $input | openssl ts -verify -in $tsr -data /dev/stdin -CAfile /etc/ssl/certs/ca-certificates.crt
        } | complete 
        if ($data.exit_code != 0) {
            error make { msg: "Could not verify!" }
        }
        let data = do {
            openssl ts -reply -in $tsr -text
        } | complete
        if ($data.exit_code != 0) {
            error make { msg: "Could not parse timestamp" }
        }
        let timestamp = $data | get stdout | 
            split row (char newline) | 
            where $it =~ "^Time stamp: " | 
            split row "Time stamp: " | get 1 | into datetime
        print "Verified"
        return $timestamp
    }
}
