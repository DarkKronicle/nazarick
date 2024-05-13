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
    nixfmt flake.nix homes/ lib/ modules/ overlays/ packages/ systems/
}

def "main commit" [message: string, --noversion] {
    do_safely {
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

def "main build" [--update, --flake: string = ".", --plain, --hostname: string] {
    do_safely {
        format
        git add .
        mut flags = [
          "os"
          "switch"
          $flake
        ];
        if ($update) {
            $flags = ($flags | append "--update")
        }
        if ($plain) {
            $flags = ($flags | append "--no-nom")
        }
        if ($hostname | is-not-empty) {
            $flags = ($flags | append "--hostname" | append $hostname)
        }
        run-external "nh" ...$flags
    }
}

def main [] {
    do_safely {
        ^$env.EDITOR flake.nix
    }
}
