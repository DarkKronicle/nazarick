# Caches a command's result and becomes accessible by `lcache`
# If the command has been run before and is cache, only the cached result will be returned
#
# This doesn't work great if you're passing in some variables, since they won't be substituted.
# Also, changing whitespace may result in some issues
#
# Examples:
#
# Run http command and get ID. This will be instant after running once
# > cache -p { http get https://api.github.com/users/DarkKronicle } | get id
# 
export def --env "main" [
    code: closure,             # The code to run
    --save(-s),                # Save the result to a file in nushell cache directory
    --force(-f),               # Regardless of cache status, run the command
    --pwd(-p),              # Don't account for pwd in the cache
    --tee(-t),                 # Tee off and print output
    --no-return(-r),           # Don't return the result after it's computed (prevents duplicate output if tee is on)
    --max-session-cache = 10,  # Max results stored in nushell session
    --max-saved-cache = 100,   # Max results stored in cache files
]: nothing -> any { 
    mut extra = []
    if ($pwd) {
        $extra = ($extra | append ("PWD: " + $env.PWD))
    }
    let hash = ($extra | str join "\n") + (view source $code) | hash md5
    if (not ("__NU_CACHED_RESULTS" in $env)) {
        $env.__NU_CACHED_RESULTS = []
    }
    mut cached = $env.__NU_CACHED_RESULTS | where ($it.hash) == $hash | get 0?
    let file = ($nu.cache-dir | path join "cached-cmds" $hash)
    if $cached == null and $save {
        if ($file | path exists) {
            $cached = { hash: $hash, file: $file }
        }
    }
    let result = if ($cached == null or $force) {
        if $tee {
            (do $code | tee { print }) 
        } else {
            do $code
        }
    } else { 
        $env.__NU_LAST_RESULT = $cached
        if "file" in $cached {
            return ($cached.file | open $in | from json)
        }
        return $cached.result
    }
    if $save {
        mkdir ($file | path dirname)
        ls ($file | path dirname) | sort-by -r modified | skip $max_saved_cache | get name | each {|x| rm -p $x }
        $result | to json | save -f $file
    } else {
        $env.__NU_CACHED_RESULTS = ($env.__NU_CACHED_RESULTS | last ($max_session_cache - 1) | append { hash: $hash, result: $result})
    }
    $env.__NU_LAST_RESULT = if $save {
        { hash: $hash, file: $file }
    } else {
        { hash: $hash, result: $result }
    }
    if (not $no_return) {
        $result
    }
}

# Clears the cache in the current session.
# If --file is passed, it clears the stored cache
export def --env clear [
    --files # Clear files
] {
    if $files {
        ls ($nu.cache-dir | path join "cached-cmds") | get name | each {|x| rm -p $x }
    } else {
        $env.__NU_CACHED_RESULTS = []
    }
    $env.__NU_LAST_RESULT = null
}

# Get the last cache result
export def "recent" [] {
    let result = $env.__NU_LAST_RESULT?
    if $result == null {
        return null
    }
    let computed = $result | get result?
    if $computed != null {
        return $computed
    }
    $result | get file | open $in | from json
}
