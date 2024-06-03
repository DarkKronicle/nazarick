def get-dolphin-dbus [] {
    (qdbus | rg 'dolphin' | split row (char newline) | get 0 | str trim)
}

def --env dolphin-dbus [dbus: string, path: string] {
    let command = if ($path | path type) == file {
        'org.kde.dolphin.MainWindow.openFiles'
    } else {
        'org.kde.dolphin.MainWindow.openDirectories'
    }
    qdbus $dbus /dolphin/Dolphin_1 $command ('file://' + $path) true
    qdbus $dbus /dolphin/Dolphin_1 org.kde.dolphin.MainWindow.activateWindow nu
}

def --env dolphin-open [path?: string] {
    let i_path = if (($path | is-empty) and ($in | is-empty)) {
        ($env.PWD | path expand)
    } else if ($path | is-empty) {
        ($in | path expand)
    } else {
        ($path | path expand)
    }

    let dbus = get-dolphin-dbus
    if (($dbus | str length) == 0) {
        # No open dolphin
        if ('app' not-in (task group)) {
            task group add app
        }
        $env.NU_DOLPHIN_OPEN = $i_path
        let task_id = (task spawn --immediate --group app {
            if ($env.NU_DOLPHIN_OPEN | path type) == file {
                dolphin --select $env.NU_DOLPHIN_OPEN
            } else {
                dolphin $env.NU_DOLPHIN_OPEN
            }

        })
        hide-env NU_DOLPHIN_OPEN
    } else {
        # Dolphin is open
        dolphin-dbus $dbus $i_path
    }
    
}
