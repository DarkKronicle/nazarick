def main [message?: string, --test, --no-build, --update] {
    nixfmt flake.nix homes/ lib/ modules/ overlays/ packages/ systems/
    git add .
    if ($update) {
        nix flake update
        git add .
    }
    if (not $no_build) {
        nom build .#nixosConfigurations.tabula.config.system.build.toplevel
        if (not $test) {
            sudo nixos-rebuild switch --flake .
        }
    }
    if (not ($message | is-empty))  {
        let generation = (nixos-rebuild list-generations --flake . | rg "current" | split row " " | filter {|x| not ($x | is-empty)} | get 0)
        git commit -m ("Gen " + $generation + ": " + $message)
    }
}
