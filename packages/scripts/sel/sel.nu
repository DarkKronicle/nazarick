#!/usr/bin/env nu

alias real-ps = ps

def sel-env [code: closure] {
    with-env {
        PATH: ($env.PATH | prepend @NIX_PATH_PREPEND@)
    } {
        do $code
    }
}

const TITLE_LEN = 30

export def "choose-window" [] {
    sel-env {
        let windows = niri msg --json windows | from json
        let workspaces = niri msg --json workspaces | from json

        let info = $windows 
            | insert workspace_index {|x|
                $workspaces | where id == $x.workspace_id | first | get idx
            } 
            | insert monitor {|x|
                $workspaces | where id == $x.workspace_id | first | get output
            } 
            | select id app_id title workspace_index monitor 
            | sort-by monitor workspace_index 
            | insert monitor_display {|x| $"[($x.workspace_index), ($x.monitor)]"}
            | update title {
                let t = $in | str trim
                if (($t | str length) > ($TITLE_LEN - 3)) {
                    ($t | str substring 0..<($TITLE_LEN - 3)) + "..."
                } else {
                    $t
                } | fill --width $TITLE_LEN
            }

        let max_app_id = $info | get app_id | each { str length } | math max
        let max_monitor_display = $info | get monitor_display | each { str length } | math max
        let display = $info 
            | update app_id { fill --width $max_app_id } 
            | update monitor_display { fill --width $max_monitor_display }

        let selected_tofi = $display | each {|x| $"($x.app_id) : ($x.title) ($x.monitor_display) ($x.id)" } | str join (char newline) | tofi --fuzzy-match=true --prompt-text="focus window: " --history=false --padding-left="10%"

        if (($selected_tofi | str trim | str length) == 0) {
            return null
        }

        let tofi_id = ($selected_tofi | split words | last | into int)
        let window = $windows | where id == $tofi_id | first
        return $window
    }
}

export def "focus-window" [] {
    let window = choose-window
    if ($window == null) {
        return
    }
    sel-env {
        niri msg action focus-window --id ($window | get id)
    }
}

export def "ps" [
    --kill(-k) # very much kill
] {
    plugin use skim;
    let process = real-ps | sk --format { get name } --preview {}
    return $process;
}

export def "pkill" [
    --kill(-k) # very much kill
] {
    let process = ps
    if ($process == null) {
        return
    }
    if ($kill) {
        kill -9 $process.pid
    } else {
        kill $process.pid
    }
}

export def "main" [] {
    plugin use skim;
}
