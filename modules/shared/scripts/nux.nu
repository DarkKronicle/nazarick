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
] {
    mut path = if ($bin and not ($path | str contains '/')) {
        $"/bin/($path)"
    } else {
        $path
    }
    mut type = if $bin {
        $type | append ['x', 's']
    } else {
        $type
    }
    mut args = []
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
    ^nix-locate ...$args $path 
        | detect columns --no-headers
        | rename -c { column0: package, column1: size, column2: type, column3: path } 
}
