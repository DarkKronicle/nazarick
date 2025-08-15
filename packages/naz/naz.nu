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

def "main stage" [] {
    do_safely {
        nix fmt
        git add .
        let generation =  (nixos-rebuild list-generations --flake . --json | from json | where current == true | first | get generation)
        print $"Generation: ($generation)"
        return $generation
    }
}

def "main build" [--update, --pull, --flake: string = ".", --plain, --hostname: string, --specialisation: string] {
    do_safely {
        git pull
        nix fmt
        git add .
        mut flags = [
          "os"
          "switch"
          $flake
        ];
        if ($update) {
            $flags = ($flags | append "--update")
            let url = "git+ssh://git@gitlab.com/DarkKronicle/nix-sops.git"
            let locked = (nix eval --impure --expr $"let content = builtins.fetchGit { url = \"($url)\"; }; noOut = builtins.removeAttrs content [ \"outPath\" ]; in noOut // { \"out\" = content.outPath; }" --json --refresh) | from json
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
        if ($specialisation | is-not-empty) {
            # TODO: Make this not depend on building in specialisation...
            sudo /nix/var/nix/profiles/system/specialisation/sway/bin/switch-to-configuration boot
        }
    }
}

def main [] {
    do_safely {
        ^$env.EDITOR flake.nix
    }
}
