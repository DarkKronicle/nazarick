#! /usr/bin/env nix
#! nix shell nixpkgs#nushell nixpkgs#ripgrep nixpkgs#nixfmt-rfc-style nixpkgs#git nixpkgs#nix-output-monitor --command nu

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

def "main push" [message?: string] {
    do_safely {
        git push
    }
}

def "main build" [message?: string, --update, --no-build, --plain] {
    do_safely {
        format
        git add .
        if ($update) {
            nix flake update
            git add .
        }
        if (not $no_build) {
            if (not $plain) {
                nom build .#nixosConfigurations.tabula.config.system.build.toplevel
            }
            sudo nixos-rebuild switch --flake .
        }
        if (not ($message | is-empty))  {
            # Set pager here to less so that there is no confusion
            let generation = PAGER="less" (nixos-rebuild list-generations --flake . | rg "current" | split row " " | filter {|x| not ($x | is-empty)} | get 0)
            git commit -m ("Gen " + $generation + ": " + $message)
        }
    }
}

def main [] {
    do_safely {
        ^$env.EDITOR flake.nix
    }
}
