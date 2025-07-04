#!/usr/bin/env nu

# https://discord.com/channels/601130461678272522/601130461678272524/1237841079781429352
def "list index-of" [value]: list -> int {
  enumerate | where item == $value | get 0?.index? | default (-1)
}

def "merge deep" [] {
    let tables = $in
    mut result = {}
    for $val in $tables {
        $result = ($result | merge $val)
    }
    $result
}

export def "sorted-displays" [] {
    let outputs = swaymsg -t get_outputs | from json
    let x_pos = $outputs | each {|x| { $x.name: $x.rect.x }} | merge deep | sort -v
    $x_pos | transpose | get column0
}

export def "tree find" [input, filter: closure, columns = [ 'nodes' 'floating_nodes' ]] {
    if (do $filter $input) {
        return $input
    } 
    for column in $columns {
        for $node in ($input | get $column) {
            let val = tree find $node $filter
            if ($val != null) {
                return $val
            }
        }
    }
    return null
}

def "listen-for" [filter: list, condition: closure, --duration(-d): duration = 30sec  ] {
    timeout (($duration | into int) / 1000000000) swaymsg -t subscribe ($filter | to json) -m 
    | from json --objects | skip until  $condition | try { first }
}

export def "kitty-start-scratch" [] {
    start-in-scratchpad "swaymsg 'exec sleep 2 && kitty zellij'" "kitty" "[con_id=|CON|] blur enable"
}

# TODO: this is ultra ugly
export def "start-in-scratchpad" [cmd: string, app_id: string, extra?: string] {
    let marks = swaymsg -t get_marks

    sh -c $cmd

    try {
        swaymsg $"mark --replace current"
    }
    let event = listen-for ["window"] {|x| $x.change == new and $x.container.app_id == $app_id}
    swaymsg $"[con_id=($event.container.id)] mark --replace tomove"
    if "scratch" in $marks {
        # DOn't ask me why 3 scratchpad shows
        swaymsg 'scratchpad show; [con_mark="tomove"] focus; move container to mark scratch; scratchpad show; unmark tomove; '
        try {
            swaymsg '[con_mark="current"] focus; unmark current'
        }
        if ($extra | is-not-empty) {
            swaymsg ($extra | str replace -a "|CON|" ($event.container.id | into string))
        }
        return
    }

    swaymsg $'[con_id=($event.container.id)] focus; splith; layout tabbed; focus parent; mark --replace scratch; move scratchpad; unmark tomove;'
    try {
        swaymsg '[con_mark="current"] focus; unmark current'
    }
    if ($extra | is-not-empty) {
        swaymsg ($extra | str replace -a "|CON|" ($event.container.id | into string))
    }

}

# Fancy scratchpad that enforces tabbed layout
export def "move-to-scratchpad" [] {
    # Check if the scratchpad tabbed layout exists
    let marks = swaymsg -t get_marks

    if "scratch" in $marks {
        # Just move to scratchpad. Have to show scratchpad first to be added to layout correctly
        swaymsg "mark --replace tomove; scratchpad show; [con_mark="tomove"] focus; move container to mark scratch; scratchpad show; unmark tomove"

        return
    }
    # Does not exist so create layout

    let tree = swaymsg -t get_tree | from json
    let focused = tree find $tree {|x| $x | get focused }
    if (($focused | get pid?) != null) {
        swaymsg 'splith; layout tabbed; focus parent; mark --replace scratch; move scratchpad'
        # An app, so funny business commence (to ensure that only the window we're focusing gets scratchpadded)
        return
    }
    swaymsg 'layout tabbed; focus parent; mark --replace scratch; move scratchpad;'
    return
}

export def "display" [order: int] {
    let prio = [ 'HDMI-A-1' 'eDP-1' ]
    mut outputs = sorted-displays
    mut i = 0
    for $display in $prio {
        let index = $outputs | list index-of $display
        if $index >= 0 {
            if $i == $order {
                return $display
            }
            $i = ($i + 1)
            $outputs = ($outputs | drop nth $index)
        }
    }
    let target = ($order - $i)
    if $target >= ($outputs | length) {
        return null
    }
    return ($outputs | get $target)
}

export def "sorted-prio" [] {
    let prio = [ 'HDMI-A-1' 'eDP-1' ]
    mut outputs = sorted-displays
    mut final = []
    for $display in $prio {
        let index = $outputs | list index-of $display
        if $index >= 0 {
            $final = ($final | append $display)
            $outputs = ($outputs | drop nth $index)
        }
    }
    ($final | append $outputs)
}

export def "init" [] {
    let outputs = sorted-prio
    mut i = 0;
    for $display in $outputs {
        swaymsg $"workspace ($i)1 output ($display); workspace ($i)1"
        swaymsg $"workspace ($i)C output ($display);"

        $i = ($i + 1)
    }
}

# Move a window to another workspace
export def "move-container" [output: int, workspace: string] {
    let display = display $output
    if $display == null {
        return
    }
    let workspaces = swaymsg -t get_workspaces | from json
    let target = $workspaces | where {|w| ($w | get name) == $workspace } | get 0?
    if $target == null {
        # Need to create it
        swaymsg $"workspace ($workspace) output ($display); move container to workspace ($workspace)"
        return
    }
    # Exists, so just move
    swaymsg $"move container to workspace ($workspace)"
    return null
}

# Swap workspace with another one that may or may not exist. Will keep focus
# On current one
# Cannot swap with the current one (doesn't make sense, needs to be able to create a new one)
export def "swap" [output: int, workspace: string] {
    let reserved = "-";
    let workspaces = swaymsg -t get_workspaces | from json
    let current = $workspaces | where {|w| $w | get focused } | get 0
    if ($current | get name) == $workspace {
        # Same workspace dingus
        return
    }
    let target = $workspaces | where {|w| ($w | get name) == $workspace } | get 0?
    let display = display $output
    let target_display = if ($target != null) { 
        $target | get output
    } else {
        $display
    }
    let same_display = ($target_display == ($current | get output))
    if ($target == null) {
        # Nothing to swap with, just may need to create a new one
        if $same_display {
            # Just rename, no need for any fancy business
            swaymsg $"rename workspace to ($workspace)"
            return
        }
        # Move displays, then rename. Restore other monitor to blank (bc it swapped with nothing)
        # Also need to refocus
        swaymsg $"move workspace to ($target_display) current; rename workspace to ($workspace); workspace ($current | get name) output ($current | get output); workspace ($current | get name); workspace ($workspace)"
        return
    }
    # Now we have to actually perform a full swap since there is something here
    if $same_display {
        swaymsg $"rename workspace to ($reserved); rename workspace ($workspace) to ($current | get name); rename workspace ($reserved) to ($workspace)"
        return
    }
    # We move it and then check if the other one exists still (if it was one on a monitor, it won't)
    swaymsg $"move workspace to ($target_display) current; rename workspace to ($reserved)"
    let workspaces = swaymsg -t get_workspaces | from json
    let target_exists = $workspaces | where {|w| ($w | get name) == $workspace } | get 0? | is-not-empty
    if $target_exists {
        swaymsg $"rename workspace ($workspace) to ($current | get name)"
    }
    swaymsg $"workspace ($current | get name); move workspace to ($current | get output) current; rename workspace ($reserved) to ($workspace); workspace ($workspace)"
    return null
}

export def "goto" [output: int, workspace: string] {
    let display = display $output
    swaymsg $"workspace ($workspace) output ($display); workspace ($workspace)"
    return null
}

