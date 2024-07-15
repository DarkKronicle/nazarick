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

def "sorted-displays" [] {
    let outputs = swaymsg -t get_outputs | from json
    let x_pos = $outputs | each {|x| { $x.name: $x.rect.x }} | merge deep | sort -v
    $x_pos | transpose | get column0
}

def "main init" [] {
    let outputs = swaymsg -t get_outputs | from json
    let x_pos = $outputs | each {|x| { $x.name: $x.rect.x }} | merge deep | sort -v
    let sorted = $x_pos | transpose | get column0
    mut i = 1;
    for $display in $sorted {
        swaymsg $"workspace ($i)0 output ($display); workspace ($i)0"

        $i = ($i + 1)
    }
}

# Move the current workspace to the left or right monitor
def "main move" [direction: int, prefix_reserved: string] {
    let workspaces = swaymsg -t get_workspaces | from json
    let sorted = sorted-displays
    if ($sorted | length) == 1 { 
        # One monitor, where would we move it to?
        return
    }
    let current = $workspaces | filter {|w| $w | get focused } | get 0
    let special = $current | get name | str starts-with $prefix_reserved
    if not $special {
        # The current workspace is bound by a monitor, use swap instead
        # TODO: check if I just want to swap it here, I don't really see a reason to
        return
    }  
    let visible = $workspaces | filter {|w| $w | get visible }
    let current_display = $current | get output
    let current_index = $sorted | list index-of $current_display
    let target_index = if $direction == 1 {
        # To the right
        if ($current_index >= (($sorted | length) - 1)) {
           -1 
        } else {
            $current_index + 1
        }
    } else {
        if ($current_index < 0) {
            -1
        } else {
            $current_index - 1
        }
    }
    if $target_index < 0 {
        # Can't go any more in the direction
        return
    }
    # Just move, don't need to ensure anything
    swaymsg $"move workspace to ($sorted | get $target_index); workspace ($current | get name)"
}

# Move a window to another workspace
def "main move-container" [output: int, workspace: string] {
    let sorted = sorted-displays
    if $output >= ($sorted | length) {
        return
    }
    let workspaces = swaymsg -t get_workspaces | from json
    let target = $workspaces | filter {|w| ($w | get name) == $workspace } | get 0
    if $target == null {
        # Need to create it
        swaymsg $"workspace ($workspace) output ($sorted | get $output); move container to workspace ($workspace)"
        return
    }
    # Exists, so just move
    swaymsg $"move container to workspace ($workspace)"
}

# Swap workspace with another one that may or may not exist. Will keep focus
# On current one
# Cannot swap with the current one (doesn't make sense, needs to be able to create a new one)
def "main swap" [left_index: int, workspace: string, prefix_reserved: string] {
    let reserved = "-";
    let workspaces = swaymsg -t get_workspaces | from json
    let current = $workspaces | filter {|w| $w | get focused } | get 0
    if ($current | get name) == $workspace {
        # Same workspace dingus
        return
    }
    let target = $workspaces | filter {|w| ($w | get name) == $workspace } | get 0?
    let sorted = sorted-displays
    let target_display = if ($target == null) { 
        if $left_index < -4 {
            $current | get output
        } else {
            $sorted | get $left_index 
        }
    } else {
        ($target | get output)
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
    let target_exists = $workspaces | filter {|w| ($w | get name) == $workspace } | get 0? | is-not-empty
    if $target_exists {
        swaymsg $"rename workspace ($workspace) to ($current | get name)"
    }
    swaymsg $"workspace ($current | get name); move workspace to ($current | get output) current; rename workspace ($reserved) to ($workspace); workspace ($workspace)"
}

# Use @WORKSPACE@ in command to specify where to replace
def "main rundisplay" [left_index: int, name_sub: string, ...command: string] {
    let sorted = sorted-displays
    if $left_index >= ($sorted | length) {
        return
    }
    let display = if $left_index < -4 {
        # Don't care about which display
        let workspaces = swaymsg -t get_workspaces | from json
        let current = $workspaces | filter {|w| $w | get focused } | get 0
        $current | get output
    } else {
        $sorted | get $left_index 
    }
    let formatted_command = $command | each { 
        |x| 
            $x | str replace --all '@WORKSPACE@' $display 
            | str replace --all '@NAME@' $name_sub
    }
    run-external ($formatted_command | get 0) ...($formatted_command | skip 1)
}

def "main" [] {
    error make { msg: "Please provide an argument" }
}
