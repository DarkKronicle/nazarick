def nux-env [code: closure] {
    with-env {
        PATH: ($env.PATH | prepend @NIX_PATH_PREPEND@)
    } {
        do $code
    }
}

export def "locate" [
    path: string, # Path of file to find
    --bin(-b), # shorthand for searching for binaries (enables -w, -g, -r, -T, and formats path with /bin/{name} if applicable)
    --whole-name(-w), # path is not a partial word
    --type(-t): list<string>, # search for types, valid are (r)egular file, (s)ymlink, (d)irectory, e(x)ecutable
    --regex(-r), # treat path as regex
    --package: string, # search from where package name equals package
    --hash: string, # search from where hash is this
    --no-group(-g), # print all matches, even if there is overlap
    --at-root(-R), # treat path as at root, so no sub directories
    --top-level(-T), # only show paths that show up in `nix-env -qa`
    --small(-S), # use small database
] {
    nux-env {
        mut args = []
        mut small = $small;
        mut path = if ($bin and not ($path | str contains '/')) {
            $small = true;
            $"/bin/($path)"
        } else {
            $path
        }
        mut type = if $bin {
            $type | append ['x', 's']
        } else {
            $type
        }
        if ($type | is-not-empty) {
            $args = ($args | append ($type | each {|t| ["--type" $t]} | flatten))
        }
        if ($bin or $whole_name) {
            $args = ($args | append "--whole-name")
        }
        if ($bin or $no_group) {
            $args = ($args | append "--no-group")
        }
        if ($bin or $at_root) {
            $args = ($args | append "--at-root")
        }
        if ($bin or $top_level) {
            $args = ($args | append "--top-level")
        }
        if ($small) {
            $args = ($args | append ["--db" "@NIX_SMALL_DB@"])
        }
        ^nix-locate ...$args $path 
            | detect columns --no-headers
            | rename -c { column0: package, column1: size, column2: type, column3: path } 
    }
}

# Convert a nixos-option output into a toml object. May not work with all, expects -r flag
export def "parse-options" [] {
    $in | ansi strip 
        | str replace -ram '«(error[\s\S]*?)»' $"'''(char newline)$1(char newline)'''" 
        | str replace -ram '(^\s+\{[\s\S]*?\}$)' $'"""(char newline)$1(char newline)""",'
        | str replace -ma ';$' '' 
        | str replace -ram '<(.*)>$' '"<$1>"'
        | str replace -ram '^(".+")$' '$1,' 
        | str replace -ram '^\s+«(.*)»' '"$1",' 
        | str replace -ra '«(.*)»' '"$1"' 
        | str replace -ram '\snull$' '"null"' | from toml
}

# Grab options from current configuration. Not all may work, but things like `nazarick`, `nixpkgs`, `xdg` do.
# So good for a quick check. Prefixes like `system` may take a *very* long time.
export def "options" [
    prefix: string # Prefix for options. Some of these can take a *long time*.
] {
  nixos-option -r $prefix | parse-options
}
