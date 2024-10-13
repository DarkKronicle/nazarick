def stl-env [code: closure] {
    with-env {
        PATH: ($env.PATH | prepend @NIX_PATH_PREPEND@)
    } {
        do $code
    }
}

def "table-to-record" [col1: string, col2: string] {
    $in | reduce -f {} {|it, acc| $acc | upsert ($it | get $col1) ($it | get $col2) }
}

def "simplify-duration" [] {
    (($in | into int) // 1000000 * 1000000) | into duration
}

def --wrapped do-sysctl [user: bool, ...$rest] {
    if ($user) {
        ^systemctl --user ...$rest
    } else {
        ^systemctl ...$rest
    }
}

def "inner-list-units" [user: bool] {
    do-sysctl $user list-units --all --no-pager -o json
        | from json
        | insert type { $in.unit | split row '.' | last }
}

def "autocomplete-any" [] {
    list-units -a | get unit | sort
}

export def "list-units" [--user(-u), --all(-a)] {
    if ($all and $user) {
        error make { msg: "Cannot combine user and all" }
    }
    if ($all) {
        let user = inner-list-units true | insert context "user"
        let system = inner-list-units false | insert context "system"
        return ($system | append $user)
    }
    inner-list-units $user | insert context (if $user { "user" } else { "system" })
}

def "inner-list-timers" [user: bool] {
    # Remove nanoseconds
    let now = date now
    do-sysctl $user list-timers --all --no-pager -o json
        | from json
        | update next { 
            if ($in == 0) {
                null
            } else {
                $in * 1000 | into datetime 
            }
        }
        | update last { 
            if ($in == 0) {
                null
            } else {
                $in * 1000 | into datetime 
            }
        }
        | reject passed left
        | insert passed { 
            if ($in.last == null) {
                null
            } else {
                $now - $in.last | simplify-duration 
            }
        }
        | insert left { 
            if ($in.next == null) {
                null
            } else {
                $in.next - $now | simplify-duration 
            }
        }
        | move left --after last
        | move passed --after left
}

export def "list-timers" [--user(-u), --all(-a)] {
    if ($all and $user) {
        error make { msg: "Cannot combine user and all" }
    }
    if ($all) {
        let user = inner-list-timers true | insert context "user"
        let system = inner-list-timers false | insert context "system"
        return ($system | append $user)
    }
    inner-list-timers $user | insert context (if $user { "user" } else { "system" })
}

def "get-best-match" [name: string, is_user: bool] {
    let units = inner-list-units $is_user | where ($name in $it.unit)
    let maybe_perfect_match = $units | where $it.unit == $name
    if ($maybe_perfect_match | is-not-empty) {
        $maybe_perfect_match | get 0
    } else {
        if ($units | is-empty) {
            error make { msg: "Unit not found" }
        }
        if (($units | length) > 1) {
            error make { msg: $"Ambiguous unit \(found ($units | get unit | str join ', '))" }
        }
        $units | get 0
    } | get unit
}

def "inner-show" [name: string, user: bool] {
    do-sysctl $user show --no-pager -- $name
        | lines | split column '=' -n 2 
        | table-to-record column1 column2 
        | convert-show
}

export def "show" [
    unit: string@autocomplete-any,
    --user(-u), 
    --context(-c): string # derive where to took from context
] {
    if ($user and ($context | is-not-empty)) {
        error make { msg: "Cannot combine user and context" }
    }
    let is_user = $user or ($context == "user")
    let unit_name = get-best-match $unit $is_user
    if ($unit_name | is-empty) {
        error make { msg: "Unit not found" }
    }
    inner-show $unit_name $is_user
}

def "systemd-into-duration" [] {
    let x = $in
    if ($x == "infinity") {
        return null
    }
    if ($x == "0") {
        return (0 | into duration)
    }
    try {
        return ($x | str replace -a -r '\[(.+)\]' '$1' | str replace -a -r '(?<=\d)s' 'sec' 
            | str replace -a -r '(?<=\d)d' 'day' 
            | str replace -a -r '(?<=\d)h' 'hr' 
            | into duration)
    } catch {
        try {
            return ((date now) - ($x | split row ' ' | drop 1 | str join ' ' | into datetime))
        } catch {
            error make { msg: $x }
        }
    }
}

def "null-if-infinity" [else: closure] {
    if ($in == "infinity") {
        return null
    }
    if ($in == "[not set]") {
        return null
    }
    if ($in == "[no data]") {
        return null
    }
    do $else $in
}

def "convert-show" [] {
    mut details = $in
    let timestamps = $in | columns | where $it =~ 'Timestamp$'
    let filesizes = [
        MemoryPeak MemoryCurrent IOReadBytes IOWriteBytes DefaultMemoryLow
        DefaultStartupMemoryLow MemorySwapCurrent MemorySwapPeak
        MemoryZSwapCurrent
        MemoryAvailable
        EffectiveMemoryMax
        EffectiveMemoryHigh
        DefaultMemoryMin MemoryMin MemoryLow
        MemoryHigh MemoryLow StartupMemoryHigh MemoryMax StartupMemoryMax
        MemorySwapMax StartupMemorySwapMax
        MemoryZSwapMax StartupMemoryZSwapMax
        MemoryLimit
    ] | append ($details | columns | where $it =~ 'Bytes$')

    let durations = [
    ] | append ($details | columns | where $it =~ 'USec')

    let nsec = [
    ] | append ($details | columns | where $it =~ 'NSec$')

    let simple_lists = [
        After Wants WantedBy Before Conflicts Requires RequiredBy RequiresMountsFor
        WantsMountsFor SystemCallFilter CapabilityBoundingSet
    ] 

    let ints = [
        SystemCallErrorNumber RestartKillSignal FinalKillSignal WatchdogSignal
        MainPID KillSignal StartLimitBurst LogLevelMax SyslogFacility SyslogLevel SyslogPriority
        OOMScoreAdjust ControlPID FileDescriptorStoreMax NFileDescriptorStore StatusErrno UID GID NRestarts
        ReloadSignal ExecMainCode ExecMainStatus
        ControlGroupId EffectiveMemoryNodes TasksCurrent EffectiveTasksMax TasksMax ManagedOOMMemoryPressureLimit
        Nice
        IOSchedulingPriority CPUSchedulingPolicy CPUSchedulingPriority LogRateLimitBurst
        SecureBits ExecMainPID IOSchedulingClass CPUWeight StartupCPUShares StartupCPUWeight RestartSteps
    ] | append ($details | columns | where $it =~ 'Monotonic$') 
            | append ($details | columns | where $it =~ '^Limit')
            | append ($details | columns | where $it =~ 'Packets$')
            | append ($details | columns | where $it =~ 'Operations$')
            | where $it != TimersMonotonic

    for col in $timestamps {
        if (($col in $details) and ($details | get $col | is-not-empty)) {
            $details = $details | update $col { split row ' ' | drop 1 | str join ' ' | into datetime }
        }
    }

    for col in $filesizes {
        if (($col in $details) and ($details | get $col | is-not-empty)) {
            $details = $details | update $col { null-if-infinity {|x| 
                $x | into filesize }}
        }
    }

    for col in $durations {
        if (($col in $details) and ($details | get $col | is-not-empty)) {
            $details = $details | update $col { systemd-into-duration }
        }
    }

    for col in $nsec {
        if (($col in $details) and ($details | get $col | is-not-empty)) {
            $details = $details | update $col { null-if-infinity {|x| $x | into int | into duration }}
        }
    }

    for col in $ints {
        if (($col in $details) and ($details | get $col | is-not-empty)) {
            $details = $details | update $col { null-if-infinity {|x| $x | into int } }
        }
    }

    $details = ($details | transpose one two | each {|x| 
        if (($x.two | describe -n) != "string") {
            $x
        } else {
            if ($x.two == "no") {
                {one: $x.one, two: false }
            } else if ($x.two == "yes") {
                {one: $x.one, two: true }
            } else {
                $x
            }
        }
    } | table-to-record one two)

    for col in $simple_lists {
        if (($col in $details) and ($details | get $col | is-not-empty)) {
            $details = $details | update $col { split row ' '}
        }
    }

    if ("Environment" in $details) {
        $details = $details | update Environment { split row ' ' | split column '=' -n 2 key value }
    }

    $details
}

export def "status" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
] {
    if ($user and ($context | is-not-empty)) {
        error make { msg: "Cannot combine user and context" }
    }
    let is_user = $user or ($context == "user")
    let unit_name = get-best-match $unit $is_user
    if ($unit_name | is-empty) {
        error make { msg: "Unit not found" }
    }
    inner-show $unit_name $is_user | select --ignore-errors ...[
        ActiveState SubState LoadState Names Description Type Restart MainPID NRestarts 
        ExecMainStartTimestamp StateChangeTimestamp MemoryCurrent MemoryPeak MemorySwapCurrent MemorySwapPeak 
        CPUUsageNSec LoadState IOReadBytes IOWriteBytes
    ]
}

def "inner-list-sockets" [user: bool] {
    do-sysctl $user list-sockets --no-pager -o json | from json
}

export def "list-sockets" [
    --user(-u),
    --all(-a)
] {
    if ($all and $user) {
        error make { msg: "Cannot combine user and all" }
    }
    if ($all) {
        let user = inner-list-sockets true | insert context "user"
        let system = inner-list-sockets false | insert context "system"
        return ($system | append $user)
    }
    inner-list-sockets $user | insert context (if $user { "user" } else { "system" })
}

def "inner-list-paths" [user: bool] {
    do-sysctl $user list-paths --no-pager -o json | from json
}

export def "list-paths" [
    --user(-u),
    --all(-a)
] {
    if ($all and $user) {
        error make { msg: "Cannot combine user and all" }
    }
    if ($all) {
        let user = inner-list-paths true | insert context "user"
        let system = inner-list-paths false | insert context "system"
        return ($system | append $user)
    }
    inner-list-paths $user | insert context (if $user { "user" } else { "system" })
}

def "inner-list-jobs" [user: bool] {
    do-sysctl $user list-jobs --no-pager -o json | from json
}

export def "list-jobs" [
    --user(-u),
    --all(-a)
] {
    if ($all and $user) {
        error make { msg: "Cannot combine user and all" }
    }
    if ($all) {
        let user = inner-list-jobs true | insert context "user"
        let system = inner-list-jobs false | insert context "system"
        return ($system | append $user)
    }
    inner-list-jobs $user | insert context (if $user { "user" } else { "system" })
}

def "inner-list-automounts" [user: bool] {
    do-sysctl $user list-automounts --no-pager -o json | from json
}

export def "list-automounts" [
    --user(-u),
    --all(-a)
] {
    if ($all and $user) {
        error make { msg: "Cannot combine user and all" }
    }
    if ($all) {
        let user = inner-list-automounts true | insert context "user"
        let system = inner-list-automounts false | insert context "system"
        return ($system | append $user)
    }
    inner-list-automounts $user | insert context (if $user { "user" } else { "system" })
}

def "check-sudo" [] {
    (do { sudo -vn } | complete | get exit_code) == 0
}

export def "logs" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
    --lines(-l): int = 50
] {
    if ($user and ($context | is-not-empty)) {
        error make { msg: "Cannot combine user and context" }
    }
    let is_user = $user or ($context == "user")
    let unit_name = get-best-match $unit $is_user
    if ($unit_name | is-empty) {
        error make { msg: "Unit not found" }
    }
    let hostname = uname | get nodename
    let content = if ($is_user) {
        journalctl --user -u $unit_name --no-pager --boot 0 --lines $lines | lines
    } else {
        journalctl -u $unit_name --lines $lines --no-pager --boot 0 | lines
    }
    $content | split column ': ' -n 2 | update column1 { split column $" ($hostname) " time context | update time { into datetime } } | flatten | flatten | rename time context message
}

export def "restart" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
    --sudo-anyways(-s) # prompt for sudo if it makes sense, not prompting if there's a cached session
] {
    if ($user and ($context | is-not-empty)) {
        error make { msg: "Cannot combine user and context" }
    }
    let is_user = $user or ($context == "user")
    let unit_name = get-best-match $unit $is_user
    if ($unit_name | is-empty) {
        error make { msg: "Unit not found" }
    }
    # Need to run sudo, don't implicitly do it, and we have a session
    if ((not $is_user) and (not $sudo_anyways) and (check-sudo)) {
        # Expire sudo (just so you're forced a prompt)
        print "Going to run sudo and there's a cached session, continue? (pass -s to remove this message)"
        if ((input "y/n: ") != "y") {
            return
        }
    }
    if $is_user {
        systemctl --user restart -- $unit_name
    } else {
        sudo systemctl restart -- $unit_name
    }
}

export def "start" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
    --sudo-anyways(-s) # prompt for sudo if it makes sense, not prompting if there's a cached session
] {
    if ($user and ($context | is-not-empty)) {
        error make { msg: "Cannot combine user and context" }
    }
    let is_user = $user or ($context == "user")
    let unit_name = get-best-match $unit $is_user
    if ($unit_name | is-empty) {
        error make { msg: "Unit not found" }
    }
    # Need to run sudo, don't implicitly do it, and we have a session
    if ((not $is_user) and (not $sudo_anyways) and (check-sudo)) {
        # Expire sudo (just so you're forced a prompt)
        print "Going to run sudo and there's a cached session, continue? (pass -s to remove this message)"
        if ((input "y/n: ") != "y") {
            return
        }
    }
    if $is_user {
        systemctl --user start -- $unit_name
    } else {
        sudo systemctl start -- $unit_name
    }
}

export def "stop" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
    --sudo-anyways(-s) # prompt for sudo if it makes sense, not prompting if there's a cached session
] {
    if ($user and ($context | is-not-empty)) {
        error make { msg: "Cannot combine user and context" }
    }
    let is_user = $user or ($context == "user")
    let unit_name = get-best-match $unit $is_user
    if ($unit_name | is-empty) {
        error make { msg: "Unit not found" }
    }
    # Need to run sudo, don't implicitly do it, and we have a session
    if ((not $is_user) and (not $sudo_anyways) and (check-sudo)) {
        # Expire sudo (just so you're forced a prompt)
        print "Going to run sudo and there's a cached session, continue? (pass -s to remove this message)"
        if ((input "y/n: ") != "y") {
            return
        }
    }
    if $is_user {
        systemctl --user stop -- $unit_name
    } else {
        sudo systemctl stop -- $unit_name
    }
}

export def "reload" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
    --sudo-anyways(-s) # prompt for sudo if it makes sense, not prompting if there's a cached session
] {
    if ($user and ($context | is-not-empty)) {
        error make { msg: "Cannot combine user and context" }
    }
    let is_user = $user or ($context == "user")
    let unit_name = get-best-match $unit $is_user
    if ($unit_name | is-empty) {
        error make { msg: "Unit not found" }
    }
    # Need to run sudo, don't implicitly do it, and we have a session
    if ((not $is_user) and (not $sudo_anyways) and (check-sudo)) {
        # Expire sudo (just so you're forced a prompt)
        print "Going to run sudo and there's a cached session, continue? (pass -s to remove this message)"
        if ((input "y/n: ") != "y") {
            return
        }
    }
    if $is_user {
        systemctl --user reload -- $unit_name
    } else {
        sudo systemctl reload -- $unit_name
    }
}

export def "freeze" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
    --sudo-anyways(-s) # prompt for sudo if it makes sense, not prompting if there's a cached session
] {
    if ($user and ($context | is-not-empty)) {
        error make { msg: "Cannot combine user and context" }
    }
    let is_user = $user or ($context == "user")
    let unit_name = get-best-match $unit $is_user
    if ($unit_name | is-empty) {
        error make { msg: "Unit not found" }
    }
    # Need to run sudo, don't implicitly do it, and we have a session
    if ((not $is_user) and (not $sudo_anyways) and (check-sudo)) {
        # Expire sudo (just so you're forced a prompt)
        print "Going to run sudo and there's a cached session, continue? (pass -s to remove this message)"
        if ((input "y/n: ") != "y") {
            return
        }
    }
    if $is_user {
        systemctl --user freeze -- $unit_name
    } else {
        sudo systemctl freeze -- $unit_name
    }
}

export def "thaw" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
    --sudo-anyways(-s) # prompt for sudo if it makes sense, not prompting if there's a cached session
] {
    if ($user and ($context | is-not-empty)) {
        error make { msg: "Cannot combine user and context" }
    }
    let is_user = $user or ($context == "user")
    let unit_name = get-best-match $unit $is_user
    if ($unit_name | is-empty) {
        error make { msg: "Unit not found" }
    }
    # Need to run sudo, don't implicitly do it, and we have a session
    if ((not $is_user) and (not $sudo_anyways) and (check-sudo)) {
        # Expire sudo (just so you're forced a prompt)
        print "Going to run sudo and there's a cached session, continue? (pass -s to remove this message)"
        if ((input "y/n: ") != "y") {
            return
        }
    }
    if $is_user {
        systemctl --user thaw -- $unit_name
    } else {
        sudo systemctl thaw -- $unit_name
    }
}
