def --env ff [dir?: string] {
    let input = $in
    let path = $dir;
    let path = if ($dir == nil or ($dir | is-empty)) {
        if ($input | is-empty) {
            ($env.PWD | path expand)
        } else {
            ($input | path expand)
        }
    } else {
        ($dir | path expand)
    }

    (fd . | str substring (($env.PWD | str length) + 1).. | fzf)
}


def --env fh [] {
    commandline (atuin history list --cmd-only | fzf)
}

