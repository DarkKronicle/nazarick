# https://github.com/nushell/nu_scripts/blob/main/custom-completions/man/man-completions.nu

def "manpages" [] {

    ^man -w
	| str trim
    | split row (char esep)
	| par-each { glob $'($in)/man?' }
	| flatten
	| par-each { ls $in | get name }
    | flatten
	| path basename
	| str replace ".gz" ""
}

export extern "man" [
    ...targets: string@"manpages"
]
