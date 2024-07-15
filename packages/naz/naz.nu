#!/usr/bin/env nu

# Yet another wrapper for a nix wrapper
let DIR = '~/nazarick'

def do_safely [code: closure] {
    let current_pwd = $env.PWD
    try {
        cd $DIR
        do $code
        cd $current_pwd
    } catch {|e|
        cd $current_pwd
        error make $e
    }
}

def format [] {
    nixfmt flake.nix outputs/ hosts/ lib/ modules/ overlays/ packages/ systems/ secrets/
}

def "main commit" [message: string, --noversion] {
    do_safely {
        format
        git add .
        if (not $noversion)  {
            # Set pager here to less so that there is no confusion
            let generation = PAGER="less" (nixos-rebuild list-generations --flake . | rg "current" | split row " " | filter {|x| not ($x | is-empty)} | get 0)
            git commit -m ("Gen " + $generation + ": " + $message)
        } else {
            git commit -m $message
        }
        git push
    }
}

def "main build" [--update, --pull, --flake: string = ".", --plain, --hostname: string, --specialisation: string] {
    do_safely {
        git pull
        format
        git add .
        mut flags = [
          "os"
          "switch"
          $flake
        ];
        if ($update) {
            $flags = ($flags | append "--update")
            let url = "git+ssh://git@gitlab.com/DarkKronicle/nix-sops.git"
            let locked = (nix eval --impure --expr $"let content = builtins.fetchGit { url = \"($url)\"; }; noOut = builtins.removeAttrs content [ \"outPath\" ]; in noOut // { \"out\" = content.outPath; }" --json) | from json
            let hash = (nix-hash --type sha256 ($locked | get out))
            ({url: ($url), rev: ($locked | get rev), sha256: ($hash)} | to json | save -f secrets/secrets.lock)
        }
        if ($plain) {
            $flags = ($flags | append "--no-nom")
        }
        if ($hostname | is-not-empty) {
            $flags = ($flags | append "--hostname" | append $hostname)
        }
        if ($specialisation | is-not-empty) {
            $flags = ($flags | append "--specialisation" | append $specialisation)
        }
        run-external "nh" ...$flags
    }
}

def main [] {
    do_safely {
        ^$env.EDITOR flake.nix
    }
}
