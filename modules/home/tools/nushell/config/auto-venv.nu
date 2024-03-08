def find-closest-dir [target: string] {
    $env.PWD
    | path split 
    | range 1.. 
    | reduce -f [($env.PWD | path split | first)] {|subdir, acc| $acc | append ([($acc | last) $subdir] | path join ) } 
    | reverse 
    | where {|subdir| [$subdir $target] | path join | path exists }
    | each {[$in $target] | path join }
}

def has-env [name: string, _env: record] {
    $name in ($_env)
}

def get-new-lib-dirs [_env: record] {
    if not $_env.PWD in $_env.NU_LIB_DIRS { return ($_env.NU_LIB_DIRS | prepend $_env.PWD) } 
    
    return $_env.NU_LIB_DIRS
}

def --env deactivate-venv [_env: record] {
    hide-env VIRTUAL_ENV    
    hide-env VIRTUAL_ENV_NAME
    
    load-env {
        PATH: ($_env.PATH | filter { |entry| ($entry | str contains -n .venv) })
        NU_LIB_DIRS: $_env.NU_LIB_DIRS
    }
}

def --env activate-venv [_env: record, virtual_env: string] {
    let bin = ([$virtual_env, "bin"] | path join)
    
    let old_path = ($_env.PATH | filter { |entry| ($entry | str contains -n .venv) })
    let venv_path = ([$virtual_env $bin] | path join)
    let new_path = ($old_path | prepend $venv_path)
    
    let new_lib_dirs = get-new-lib-dirs $_env

    load-env {
        PATH: $new_path
        VIRTUAL_ENV: $virtual_env
        NU_LIB_DIRS: $new_lib_dirs
        VIRTUAL_ENV_NAME: ($virtual_env | path split | last 2 | get 0)    
    }
}

export def --env auto-venv-toggle [_env: record] {
    let find_closest_venv_result = find-closest-dir ".venv"

    if ($find_closest_venv_result | is-empty) == true {
        if ('VIRTUAL_ENV' in $_env) == true {
            deactivate-venv $_env
        }
        return
    }

    let $virtual_env = $find_closest_venv_result | first
    let $virtual_env_name = $virtual_env | path split | last 2 | get 0
    
    if ('VIRTUAL_ENV' in $_env) == false {
        activate-venv $_env $virtual_env
        return
    }

    if ('VIRTUAL_ENV' in $_env) and ('VIRTUAL_ENV_NAME' in $_env) and $_env.VIRTUAL_ENV_NAME != $virtual_env_name {
        activate-venv $_env $virtual_env
    }
}


