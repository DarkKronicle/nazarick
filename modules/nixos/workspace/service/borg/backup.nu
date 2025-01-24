#!/usr/bin/env nu

# Checks
def has-backup [backup_path: path] {
    if not ($backup_path | path exists) {
        return false
    }
    let prev_date = (open $backup_path | into datetime | into record | reject hour minute second timezone nanosecond)
    let now_date = (date now | into record | reject hour minute second timezone nanosecond)
    return ($prev_date == $now_date)
}

def update-file [backup_path: path] {
    date now | save -f $backup_path
}

# Actually backing up
def "backup-borg" [prefix: string, --exclude: path, ...paths: path] {
    let backup_name = ('::' + $prefix + '-{now:%Y-%m-%d_%H:%M}')
    let args = ([
        '-p',
        (if ($exclude | is-empty) { [] } else {
            [
                '--exclude-from',
                $exclude,
            ]
        })
        '--compression',
        'zstd,10',
        $backup_name,
        ...$paths
    ] | flatten)
    borg create ...$args
}

def "backup-borg-default" [repo: string, password: string, exclude: path] {
    $env.BORG_REPO = $repo
    $env.BORG_PASSPHRASE = $password

    let persist = [
      "/persist/keep"
    ]
    let secret = [
      "/home/darkkronicle/Documents/syncthing/keepass"
      "/home/darkkronicle/Documents/tomb"
    ]
    backup-borg 'all' --exclude $exclude ...$persist
    backup-borg 'secret' ...$secret
}

def cpu-snapshot [] {
    # Averages cpu usage over about 8 seconds
    1..5 | each { sleep 1sec; sys cpu -l | get cpu_usage | math avg } | math avg
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

def main [repo: string, password: string, --force, exclude: path] {
    let backup_path = '/home/darkkronicle/.borg/last_backup.txt'
    mut check_count = 0

    while not $force {
        if (has-backup $backup_path) {
            print '[BACKUP] Backed up today: skipping'
            return
        }
        if ($check_count > 6) {
            print "[BACKUP] too much CPU usage, cancelling"
            break
        }
        let cpu = (cpu-usage)
        if $cpu > 30 {
            print "[BACKUP] CPU usage too high, trying again in 5 minutes"
            sleep 5min
        } else {
            print ("[BACKUP] CPU usage at " + ($cpu | into string))
            break
        }
        $check_count += 1
    }
    print "[BACKUP] initiating backup"
    backup-borg-default $repo $password $exclude
    update-file $backup_path
}
