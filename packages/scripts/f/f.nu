def f-env [code: closure] {
    with-env {
        PATH: ($env.PATH | prepend @NIX_PATH_PREPEND@)
    } {
        do $code
    }
}

def "str starts-with-remove" [compare: string]: string -> string {
    let val = $in
    if ($val | str starts-with $compare) {
        return ($val | str substring (($compare | str length) + 1)..)
    }
    return $val
}

export def main [
    search?: string,
    --hide(-H),    # Hide .hidden files
    --ignore(-I),  # Obey .gitnore and other vsc
    --case-sensitive(-C),  # Obey .gitnore and other vsc
    --max-depth: int (-x) = -1,  # Maximum depth
    --min-depth: int (-n) = -1,  # Minimum depth
    --exclude: list<string> (-E) = [], # Exclude glob patterns
    --directory: string (-d), # Change search directory
    --regex(-r), # Perform regex search
    --extra-condtions(-s): list<string> = [], # Add extra conditions (binary and)
    --pretty(-p), # Display the result as a formatted string
    --no-pretty(-P), # Skip pretty and force returning a value
    --action(-a): closure, # perform action on result list. Useful for pretty printing.
] {
    f-env {

        mut search = $search
        mut max_depth = $max_depth
        mut pretty = $pretty
        if ($search == null) {
            $search = "*"
            if ($max_depth == -1) {
                $max_depth = 1
            }
            $pretty = true
        }
        mut flags = []
        if (not $hide) {
            $flags = $flags | append "--hidden"
        }
        if (not $ignore) {
            $flags = $flags | append "-I"
        }
        if ($case_sensitive) {
            $flags = $flags | append "--case-sensitive"
        }
        if ($max_depth > -1) {
            $flags = $flags | append ["--max-depth" ($max_depth | into string)]
        }
        if ($min_depth > -1) {
            $flags = $flags | append ["--min-depth" ($min_depth | into string)]
        }
        for $ex in $exclude {
            $flags = $flags | append ["--exclude" $ex]
        }
        for $ex in $extra_condtions {
            $flags = $flags | append ["--and" $ex]
        }
        # Directory is the second argument for fd
        mut real_dir = $directory
        if ($real_dir | is-not-empty) {
            if (not ($real_dir | path expand | path exists)) {
                try {
                    let z_dir = zoxide query $real_dir
                    $real_dir = $z_dir
                }
            } else {
                $real_dir = $real_dir | path expand
            }
        } else {
            $real_dir = pwd
        }
        $flags = [$real_dir] | append $flags 
        if (not $regex) {
            $flags = $flags | append "--glob"
        }
        # Make immutable
        let $real_dir = $real_dir

        let action = $action | default { $in }

        let results = fd $search ...$flags | lines | par-each { ls -D $in | get 0 } | sort-by "name" | do $action
        if ($pretty and not ($no_pretty)) {
            if ($real_dir != (pwd)) {
                print $"($real_dir) (char newline)└─>"
            }
            $results | update name { str starts-with-remove $real_dir } | update name {|x| 
                if ($x.type == "dir") {
                    $" ($x.name)"
                } else {
                    $x | grid --icons | str trim 
                }
            } | reject type | move size --first | move modified --after size | metadata set --datasource-ls | table -t light -i false
        } else {
            return $results 
        }
    }
}
