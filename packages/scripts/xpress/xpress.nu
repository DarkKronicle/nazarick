def "packaged" [code: closure] {
    with-env {
        PATH: ($env.PATH | prepend @NIX_PATH_PREPEND@)
    } {
        do $code
    }
}

def "inner-compress" [files: list<path>, output: path] {
    let name = $output | path basename
    let stem = $output | path parse | get stem
    mkdir ($output | path dirname)
    let files = $files | each {|x|
        if ($x | str starts-with ($env.PWD + "/")) {
            $x | str replace ($env.PWD + "/") ''
        } else {
            $x
        }
    }
    if $name =~ '\.tar$' {
        return (tar cf $output ...$files)
    }
    if $name =~ '\.tar\.gz(?:ip)?$' {
        return (tar c ...$files | crabz -f gzip | save $output)
    }
    if $name =~ '\.tar\.bgz(?:f)?$' {
        return (tar c ...$files | crabz -f bgzf | save $output)
    }
    if $name =~ '\.tar\.mgz(?:ip)?$' {
        return (tar c ...$files | crabz -f mgzip | save $output)
    }
    if $name =~ '\.tar\.zl(?:ib)?$' {
        return (tar c ...$files | crabz -f zlib | save $output)
    }
    if $name =~ '\.tar\.sz$' {
        return (tar c ...$files | crabz -f snap | save $output)
    }
    # deflate
    if $name =~ '\.tar\.zz$' {
        return (tar c ...$files | crabz -f deflate | save $output)
    }
    if $name =~ '\.tar\.df$' {
        return (tar c ...$files | crabz -f deflate | save $output)
    }

    if $name =~ '\.tar\.zst(?:d)?$' {
        return (tar c ...$files | zstd -o $file)
    }

    if $name =~ '\.tar\.xz$' {
        return (tar c ...$files | xz --stdout | save $output)
    }

    if $name =~ '\.tar\.lz(?:ma)?$' {
        return (tar c ...$files | xz --format=lzma --stdout | save $output)
    }

    if $name =~ '\.tar\.\w+$' {
        error make {
            msg: "Unsupported tar type"
        }
    }

    if $name =~ '\.zip$' {
        return (^zip -r $output ...$files)
    }

    if $name =~ '\.7z$' {
        return (7za a $output ...$files)
    }

    if (($files | length) > 1) {
        error make {
            msg: "That compression format does not support multiple files"
        }
    }

    if $name =~ '.gz(?:ip)?$' {
        return (crabz ...$files -f gzip | save $output)
    }
    if $name =~ '\.bgz(?:f)?$' {
        return (crabz ...$files -f bgzf | save $output)
    }
    if $name =~ '\.mgz(?:ip)?$' {
        return (crabz ...$files -f mgzip | save $output)
    }
    if $name =~ '\.zl(?:ib)?$' {
        return (crabz ...$files -f zlib | save $output)
    }
    if $name =~ '\.sz$' {
        return (crabz ...$files -f snap | save $output)
    }
    # deflate
    if $name =~ '\.zz$' {
        return (crabz ...$files -f deflate | save $output)
    }
    if $name =~ '\.df$' {
        return (crabz ...$files -f deflate | save $output)
    }

    if $name =~ '\.xz$' {
        return (xz $file --stdout | save $output)
    }
    
    if $name =~ '\.lz(?:ma)?$' {
        return (xz $file --format=lzma --stdout | save $output)
    }

    if $name =~ '\.zst(?:d)?$' {
        return (zstd $file -o $output)
    }

    error make {
        msg: "Unsupported file type"
    }
}

def "inner-decompress" [file: path, --directory(-d): path] {
    if (not ($file | path exists)) {
        error make {
            msg: "No such file"
        }
    }
    let name = $file | path basename
    let stem = $file | path parse | get stem
    let directory = if ($directory | is-empty) {
        '.' | path expand
    } else {
        $directory
    }
    mkdir $directory
    if $name =~ '\.tar$' {
        return (tar xf $file --directory $directory)
    }
    if $name =~ '\.tar\.gz(?:ip)?$' {
        return (crabz -d $file -f gzip | tar x --directory $directory)
    }
    if $name =~ '\.tar\.bgz(?:f)?$' {
        return (crabz -d $file -f bgzf | tar x --directory $directory)
    }
    if $name =~ '\.tar\.mgz(?:ip)?$' {
        return (crabz -d $file -f mgzip | tar x --directory $directory)
    }
    if $name =~ '\.tar\.zl(?:ib)?$' {
        return (crabz -d $file -f zlib | tar x --directory $directory)
    }
    if $name =~ '\.tar\.sz$' {
        return (crabz -d $file -f snap | tar x --directory $directory)
    }
    # deflate
    if $name =~ '\.tar\.zz$' {
        return (crabz -d $file -f deflate | tar x --directory $directory)
    }
    if $name =~ '\.tar\.df$' {
        return (crabz -d $file -f deflate | tar x --directory $directory)
    }

    if $name =~ '\.tar\.zst(?:d)?$' {
        return (zstd --decompress $file --stdout | tar x --directory $directory)
    }

    if $name =~ '\.tar\.xz$' {
        return (xz --decompress $file --stdout | tar x --directory $directory)
    }

    if $name =~ '\.tar\.lz(?:ma)?$' {
        return (xz --decompress $file --format=lzma --stdout | tar x --directory $directory)
    }

    if $name =~ '\.tar\.\w+$' {
        error make {
            msg: "Unsupported tar type"
        }
    }

    if $name =~ '.gz(?:ip)?$' {
        return (crabz -d $file -f gzip --output ($directory | path join $stem))
    }
    if $name =~ '\.bgz(?:f)?$' {
        return (crabz -d $file -f bgzf --output ($directory | path join $stem))
    }
    if $name =~ '\.mgz(?:ip)?$' {
        return (crabz -d $file -f mgzip --output ($directory | path join $stem))
    }
    if $name =~ '\.zl(?:ib)?$' {
        return (crabz -d $file -f zlib --output ($directory | path join $stem))
    }
    if $name =~ '\.sz$' {
        return (crabz -d $file -f snap --output ($directory | path join $stem))
    }
    # deflate
    if $name =~ '\.zz$' {
        return (crabz -d $file -f deflate --output ($directory | path join $stem))
    }
    if $name =~ '\.df$' {
        return (crabz -d $file -f deflate --output ($directory | path join $stem))
    }

    if $name =~ '\.xz$' {
        return (xz --decompress $file --stdout | save ($directory | path join $stem))
    }
    
    if $name =~ '\.lz(?:ma)?$' {
        return (xz --decompress $file --format=lzma --stdout | save ($directory | path join $stem))
    }

    if $name =~ '\.zst(?:d)?$' {
        return (zstd --decompress $file --output-dir-mirror $directory)
    }

    if $name =~ '\.zip$' {
        return (unzip $file -d $directory)
    }

    if $name =~ '\.7z$' {
        return (7za x $file $"-o($directory)")
    }

    error make {
        msg: "Unsupported file type"
    }

}

export def "compress" [files: list<path>, output: path] {
    packaged {
        inner-compress $files $output
    }
}

export def "decompress" [file: path, --directory(-d): path] {
    packaged {
        if ($directory | is-empty) {
            inner-decompress $file
        } else {
            inner-decompress $file -d $directory
        }
    }
}
