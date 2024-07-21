def main [] {
    let actions = {
        "split vertical": [ "swaymsg" "splitv" ],
        "split horizontal": ["swaymsg" "splitv"],
        "layout split": ["swaymsg" "layout toggle split"],
        "layout tabbed": [ "swaymsg" "layout tabbed" ],
        "layout stacking": [ "swaymsg" "layout stacking" ],
        "logout": [ "swaymsg" "exec wlogout" ],
    }
    let action = $actions | columns | str join (char newline) | tofi
    if ($action | is-empty) {
        return
    }
    let cmd = $actions | get $action
    ^($cmd | get 0) ...($cmd | skip 1)
}
