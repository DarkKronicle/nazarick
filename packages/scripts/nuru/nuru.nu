#!/usr/bin/env nu

def nuru-env [code: closure] {
    with-env {
        PATH: ($env.PATH | prepend @NIX_PATH_PREPEND@)
    } {
        do $code
    }
}

export def "move-column-new-above-workspace" [] {
    nuru-env {
        let workspaces = niri msg --json workspaces | from json | sort-by idx

        let current_monitor = $workspaces | where is_focused == true | first | get output
        let monitor_spaces = $workspaces | where output == $current_monitor

        let current_index = $monitor_spaces | where is_focused == true | first | get idx
        let max_index = $monitor_spaces | last | get idx

        # Move current column to empty workspace (this will always exist, blank named workspaces don't affect this)
        niri msg action move-column-to-workspace --focus false $max_index

        # Move it up
        niri msg action move-workspace-to-index --reference $max_index $current_index

        niri msg action focus-workspace $current_index
    }
}

export def "move-column-new-below-workspace" [] {
    nuru-env {
        let workspaces = niri msg --json workspaces | from json | sort-by idx

        let current_monitor = $workspaces | where is_focused == true | first | get output
        let monitor_spaces = $workspaces | where output == $current_monitor

        let current_index = $monitor_spaces | where is_focused == true | first | get idx
        let max_index = $monitor_spaces | last | get idx

        # Move current column to empty workspace (this will always exist, blank named workspaces don't affect this)
        niri msg action move-column-to-workspace --focus false $max_index

        # Move it up
        niri msg action move-workspace-to-index --reference $max_index ($current_index + 1)

        niri msg action focus-workspace ($current_index + 1)
    }
}
