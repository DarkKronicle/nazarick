def f-env [code: closure] {
    with-env {
        PATH: ($env.PATH | prepend @NIX_PATH_PREPEND@)
    } {
        do $code
    }
}

# Utility function to remove a string only if the input starts with it
def "str starts-with-remove" [compare: string]: string -> string {
    let val = $in
    if ($val | str starts-with $compare) {
        return ($val | str substring (($compare | str length) + 1)..)
    }
    return $val
}

# A fancy wrapper for the `fd` utility for ease of use and fancy displaying
# 
# It provides frequently used options and integrates well with nushell. 
# If no arguments are provided, it pretty prints contents of the current directory.
export def main [
    search?: string,
    --hide(-H),    # Hide .hidden files and git ignored
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
        # Set these to mutable since they can change based on empty query
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

        # Build flags list
        mut flags = []
        if (not $hide) {
            $flags = $flags | append ["--hidden" "-I"]
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

        # Run zoxide on the directory if the directory doesn't exist
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

        # Default to glob for simplicity
        if (not $regex) {
            $flags = $flags | append "--glob"
        }

        # Make immutable for closure
        let $real_dir = $real_dir

        let action = $action | default { $in }

        # Build results
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
