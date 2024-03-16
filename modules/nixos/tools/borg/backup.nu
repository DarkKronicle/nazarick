#!/usr/bin/env nu

# Checks
def backuped_today [backup_path: path] {
    if not ($backup_path | path exists) {
        return false
    }
    let prev_date = (open $backup_path | into datetime | date to-table | reject hour minute second timezone nanosecond)
    let now_date = (date now | date to-table | reject hour minute second timezone nanosecond)
    return ($prev_date == $now_date)
}

def update_file [backup_path: path] {
    date now | save -f $backup_path
}

def check_ready [] {
    # FIX: This will still return true if it's like 'MyLue' or something jank
    wifi = 'CHANGEME'
    if not (($wifi + ' ') in (nmcli connection show --active)) {
        return false
    }
    if not ('Status: Disconnected' in (nordvpn status)) {
        return false
    }
    return true
}

# Actually backing up

def "backup-borg" [prefix: string, ...paths: path] {
    let backup_name = ('::' + $prefix + '-{now:%Y-%m-%d_%H:%M}')
    let args = [
        # '-p',
        '--exclude-from',
        '/home/darkkronicle/.config/borg/exclude.txt',
        '--compression',
        'zstd,10',
        $backup_name,
        ...$paths
    ]
    borg create ...$args
}


def "backup-borg-default" [] {
    $env.BORG_REPO = $SOPS_REPO
    $env.BORG_PASSPHRASE = (open '/root/borg_password.txt' --raw | str trim)

    echo $env.BORG_REPO

    let home_dir = "/home/darkkronicle"
    let home_dirs = [
        ($home_dir + /.config),
        ($home_dir + /programming),
        ($home_dir + /.factorio),
        ($home_dir + /.ssh),
        ($home_dir + /.keys),
        ($home_dir + /.gnupg),
        ($home_dir + /.local/share/Anki2),
        ($home_dir + /.local/share/atuin),
        # ($home_dir + /.local/share/fonts),
        # ($home_dir + /.local/share/kwalletd),
        # ($home_dir + /.local/share/pueue),
        # ($home_dir + /.local/share/task),
        ($home_dir + /.local/share/PrismLauncher/instances),
        ($home_dir + /.gitconfig),
        ($home_dir + /Documents),
        ($home_dir + /.wifi),
        # ($home_dir + /.backup),
        # ($home_dir + /syncthing),
        '/root/borg',
    ]
    # TODO: Pero removed
    let pero = '/run/media/darkkronicle/peroroncino'
    let pero_dirs = [
        ($pero + '/documents'),
        ($pero + '/images'),
        ($pero + '/wallpapers'),
    ]
    backup-borg 'all' ...$home_dirs
}

def cpu-snapshot [] {
    let idle = top -bn1 | rg '%Cpu' | str trim | split row ':' | split row ',' | find 'id' | get 0 | str trim; 
    (100 - (($idle | str substring ..(($idle | str length) - 3)) | into float))
}

def cpu-usage [] {
    mut total = 0
    let amount = 5;
    for num in 1..$amount {
        $total = ($total + (cpu-snapshot))
        sleep 1sec
    }
    ($total / $amount)
}

def main [--force] {
    let backup_path = '/root/borg/last_backup.txt'

    while not $force {
        if (backuped_today $backup_path) {
            echo '[BACKUP] Backed up today: skipping'
            return
        }
        if not (check_ready) {
            echo "[BACKUP] Invalid connection: skipping"
                return
        }
        let cpu = (cpu-usage)
        if $cpu > 30 {
            echo "[BACKUP] CPU usage too high, trying again in 5 minutes"
            sleep 5min
        } else {
            echo ("[BACKUP] CPU usage at " + ($cpu | into string))
            break
        }
    }
    echo "[BACKUP] initiating backup"
    backup-borg-default
    update_file $backup_path

}
