#!/usr/bin/env nu

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

def "backup-borg-default" [exclude: path] {
    let persist = [
      "/persist/keep"
      "/mnt/fluder/3610"
      "/mnt/fluder/3500"
      "/mnt/fluder/3030"
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
    $env.BORG_REPO = $repo
    $env.BORG_PASSPHRASE = $password

    let last_backup = borg list --last 1 --json --glob all-* | from json | get archives.time.0 | into datetime
    mut check_count = 0

    while not $force {
        if ((date now) - ($last_backup) < 6hr) {
            print '[BACKUP] Backed up within the last 6 hours: skipping'
            return
        }
        if ($check_count > 6) {
            print "[BACKUP] too much CPU usage, cancelling"
            return
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
    backup-borg-default $exclude
}
