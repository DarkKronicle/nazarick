const show_columns =  {
    strings: [ Result Id Description AccessSELinuxContext LoadState ActiveState SubState FreezerState FragmentPath SourcePath UnitFileState UnitFilePreset Unit OnSuccessJobMode OnFailureJobMode JobTimeoutAction JobTimeoutRebootArgument Job LoadError StartLimitAction FailureAction SuccessAction RebootArgument CollectMode Type ExitType Restart RestartMode PIDFile NotifyAccess TimeoutStartFailureMode TimeoutStopFailureMode BusName FileDescriptorStorePreserve StatusText ReloadResult CleanResult USBFunctionDescriptors USBFunctionStrings OOMPolicy Slice ControlGroup DelegateSubgroup DevicePolicy ManagedOOMSwap ManagedOOMMemoryPressure ManagedOOMPreference MemoryPressureWatch WorkingDirectory RootDirectory RootImage RootHashPath RootHashSignaturePath RootVerity StandardInput StandardInputFileDescriptorName StandardOutput StandardOutputFileDescriptorName StandardError StandardErrorFileDescriptorName TTYPath SyslogIdentifier LogNamespace User Group PAMName ProtectHome ProtectSystem UtmpIdentifier UtmpMode Personality RuntimeDirectoryPreserve KeyringMode ProtectProc ProcSubset NetworkNamespacePath IPCNamespacePath RootImagePolicy MountImagePolicy ExtensionImagePolicy KillMode UMask RuntimeDirectoryMode StateDirectoryMode CacheDirectoryMode LogsDirectoryMode ConfigurationDirectoryMode Conditions Asserts ActivationDetails TimersMonotonic TimersCalendar RestartPreventExitStatus RestartForceExitStatus SuccessExitStatus OpenFile ExecCondition ExecConditionEx ExecStartPre ExecStartPreEx ExecStart ExecStartEx ExecStartPost ExecStartPostEx ExecReload ExecReloadEx ExecStop ExecStopEx ExecStopPost ExecStopPostEx IODeviceWeight IOReadBandwidthMax IOWriteBandwidthMax IOReadIOPSMax IOWriteIOPSMax BlockIODeviceWeight BlockIOReadBandwidth BlockIOWriteBandwidth DeviceAllow IPAddressAllow IPAddressDeny BPFProgram SocketBindAllow SocketBindDeny RestrictNetworkInterfaces NFTSet EnvironmentFiles RootImageOptions ExtensionImages MountImages LogExtraFields LogFilterPatterns SetCredential SetCredentialEncrypted LoadCredential LoadCredentialEncrypted SELinuxContext AppArmorProfile SmackProcessLabel SystemCallLog RestrictAddressFamilies RuntimeDirectorySymlink StateDirectorySymlink CacheDirectorySymlink LogsDirectorySymlink RestrictFileSystems BindPaths BindReadOnlyPaths TemporaryFileSystem ExecStopPre BindIPv6Only BindToDevice SocketUser SocketGroup Timestamping TCPCongestion SmackLabel SmackLabelIPIn SmackLabelIPOut FileDescriptorName DirectoryMode SocketMode Listen Symlinks Version Features Architecture Tainted DefaultStandardOutput DefaultStandardError SystemState DefaultMemoryPressureWatch DefaultOOMPolicy CtrlAltDelBurstAction LogLevel LogTarget SysFSPath Where What Options SloppyOptions ExecMount ExecActivate ]
    bools: [ CanStart CanStop CanReload CanIsolate CanFreeze StopWhenUnneeded RefuseManualStart RefuseManualStop AllowIsolate DefaultDependencies SurviveFinalKillSignal IgnoreOnIsolate NeedDaemonReload ConditionResult AssertResult Transient Perpetual OnClockChange OnTimezoneChange FixedRandomDelay Persistent WakeSystem RemainAfterElapse RootDirectoryStartOnly RemainAfterExit GuessMainPID Delegate CPUAccounting IOAccounting BlockIOAccounting MemoryAccounting MemoryZSwapWriteback TasksAccounting IPAccounting CoredumpReceive RootEphemeral CPUAffinityFromNUMA CPUSchedulingResetOnFork NonBlocking TTYReset TTYVHangup TTYVTDisallocate SyslogLevelPrefix DynamicUser SetLoginEnvironment RemoveIPC PrivateTmp PrivateDevices ProtectClock ProtectKernelTunables ProtectKernelModules ProtectKernelLogs ProtectControlGroups PrivateNetwork PrivateUsers PrivateMounts PrivateIPC SameProcessGroup IgnoreSIGPIPE NoNewPrivileges LockPersonality MemoryDenyWriteExecute RestrictRealtime RestrictSUIDSGID MountAPIVFS ProtectHostname MemoryKSM SendSIGKILL SendSIGHUP RestrictNamespaces Accept FlushPending Writable KeepAlive NoDelay FreeBind Transparent Broadcast PassCredentials PassFileDescriptorsToExec PassSecurity PassPacketInfo RemoveOnStop ReusePort MakeDirectory ConfirmSpawn ShowStatus DefaultCPUAccounting DefaultBlockIOAccounting DefaultIOAccounting DefaultIPAccounting DefaultMemoryAccounting DefaultTasksAccounting LazyUnmount ForceUnmount ReadWriteOnly ServiceWatchdogs ]
    filesizes: [ MemoryPeak MemoryCurrent IOReadBytes IOWriteBytes DefaultMemoryLow DefaultStartupMemoryLow MemorySwapCurrent MemorySwapPeak MemoryZSwapCurrent MemoryAvailable EffectiveMemoryMax EffectiveMemoryHigh DefaultMemoryMin MemoryMin MemoryLow MemoryHigh MemoryLow StartupMemoryHigh MemoryMax StartupMemoryMax MemorySwapMax StartupMemorySwapMax MemoryZSwapMax StartupMemoryZSwapMax MemoryLimit IPIngressBytes IPEgressBytes IOReadBytes IOWriteBytes ]
    durations: [ RestartUSec RestartMaxDelayUSec RestartUSecNext TimeoutStartUSec TimeoutStopUSec TimeoutAbortUSec RuntimeMaxUSec RuntimeRandomizedExtraUSec WatchdogUSec CPUQuotaPerSecUSec CPUQuotaPeriodUSec IODeviceLatencyTargetUSec MemoryPressureThresholdUSec LogRateLimitIntervalUSec TimeoutCleanUSec RandomizedDelayUSec AccuracyUSec LastTriggerUSec StartLimitIntervalUSec JobTimeoutUSec JobRunningTimeoutUSec TimeoutUSec KeepAliveTimeUSec KeepAliveIntervalUSec DeferAcceptUSec TriggerLimitIntervalUSec PollLimitIntervalUSec DefaultTimerAccuracyUSec DefaultTimeoutStartUSec DefaultTimeoutStopUSec DefaultTimeoutAbortUSec DefaultDeviceTimeoutUSec DefaultRestartUSec DefaultStartLimitIntervalUSec DefaultMemoryPressureThresholdUSec RuntimeWatchdogUSec RuntimeWatchdogPreUSec RebootWatchdogUSec KExecWatchdogUSec ]
    nsec: [ CPUUsageNSec TimerSlackNSec ]
    simple_lists: [ After Wants WantedBy Before Conflicts Requires RequiredBy RequiresMountsFor WantsMountsFor SystemCallFilter CapabilityBoundingSet Names Following Requisite RequisiteOf PartOf BindsTo BoundBy UpheldBy ConsistsOf ConflictedBy OnSuccess OnSuccessOf OnFailure OnFailureOf Upholds Triggers TriggeredBy PropagatesReloadTo ReloadPropagatedFrom PropagatesStopTo StopPropagatedFrom JoinsNamespaceOf SliceOf Documentation DropInPaths CanClean Markers Refs DelegateControllers IPIngressFilterPath IPEgressFilterPath DisableControllers Environment PassEnvironment UnsetEnvironment ExtensionDirectories ImportCredential SupplementaryGroups ReadWritePaths ReadOnlyPaths InaccessiblePaths ExecPaths NoExecPaths ExecSearchPath SystemCallArchitectures RuntimeDirectory StateDirectory CacheDirectory LogsDirectory ConfigurationDirectory AmbientCapabilities UnitPath Paths ]
    timestamps: [ StateChangeTimestamp InactiveExitTimestamp ActiveEnterTimestamp ActiveExitTimestamp InactiveEnterTimestamp ConditionTimestamp AssertTimestamp WatchdogTimestamp ExecMainStartTimestamp ExecMainExitTimestamp ExecMainHandoffTimestamp NextElapseUSecRealtime NextElapseUSecMonotonic LastTriggerUSecMonotonic UserspaceTimestamp FinishTimestamp GeneratorsStartTimestamp GeneratorsFinishTimestamp UnitsLoadStartTimestamp UnitsLoadFinishTimestamp ]
    ints: [ SystemCallErrorNumber RestartKillSignal FinalKillSignal WatchdogSignal MainPID KillSignal StartLimitBurst LogLevelMax SyslogFacility SyslogLevel SyslogPriority OOMScoreAdjust ControlPID FileDescriptorStoreMax NFileDescriptorStore StatusErrno UID GID NRestarts ReloadSignal ExecMainCode ExecMainStatus ControlGroupId EffectiveMemoryNodes TasksCurrent EffectiveTasksMax TasksMax ManagedOOMMemoryPressureLimit Nice IOSchedulingPriority CPUSchedulingPolicy CPUSchedulingPriority LogRateLimitBurst SecureBits ExecMainPID IOSchedulingClass CPUWeight StartupCPUShares StartupCPUWeight RestartSteps WatchdogTimestampMonotonic ExecMainStartTimestampMonotonic ExecMainExitTimestampMonotonic ExecMainHandoffTimestampMonotonic LimitCPU LimitCPUSoft LimitFSIZE LimitFSIZESoft LimitDATA LimitDATASoft LimitSTACK LimitSTACKSoft LimitCORE LimitCORESoft LimitRSS LimitRSSSoft LimitNOFILE LimitNOFILESoft LimitAS LimitASSoft LimitNPROC LimitNPROCSoft LimitMEMLOCK LimitMEMLOCKSoft LimitLOCKS LimitLOCKSSoft LimitSIGPENDING LimitSIGPENDINGSoft LimitMSGQUEUE LimitMSGQUEUESoft LimitNICE LimitNICESoft LimitRTPRIO LimitRTPRIOSoft LimitRTTIME LimitRTTIMESoft IPIngressPackets IPEgressPackets IOReadOperations IOWriteOperations StateChangeTimestampMonotonic InactiveExitTimestampMonotonic ActiveEnterTimestampMonotonic ActiveExitTimestampMonotonic InactiveEnterTimestampMonotonic ConditionTimestampMonotonic AssertTimestampMonotonic CPUShares IOWeight StartupIOWeight BlockIOWeight StartupBlockIOWeight StartupMemoryLow CoredumpFilter MountFlags  FailureActionExitStatus SuccessActionExitStatus NUMAPolicy TTYRows TTYColumns ReceiveBuffer SendBuffer Priority IPTOS IPTTL Mark SocketProtocol Backlog KeepAliveProbes MaxConnections MaxConnectionsPerSource NConnections NAccepted NRefused TriggerLimitBurst PollLimitBurst MessageQueueMaxMessages MessageQueueMessageSize PipeSize FirmwareTimestampMonotonic LoaderTimestampMonotonic KernelTimestampMonotonic InitRDTimestampMonotonic UserspaceTimestampMonotonic FinishTimestampMonotonic ShutdownStartTimestampMonotonic SecurityStartTimestampMonotonic SecurityFinishTimestampMonotonic GeneratorsStartTimestampMonotonic GeneratorsFinishTimestampMonotonic UnitsLoadStartTimestampMonotonic UnitsLoadFinishTimestampMonotonic UnitsLoadTimestampMonotonic InitRDSecurityStartTimestampMonotonic InitRDSecurityFinishTimestampMonotonic InitRDGeneratorsStartTimestampMonotonic InitRDGeneratorsFinishTimestampMonotonic InitRDUnitsLoadStartTimestampMonotonic InitRDUnitsLoadFinishTimestampMonotonic WatchdogLastPingTimestampMonotonic DefaultLimitCPU DefaultLimitCPUSoft DefaultLimitFSIZE DefaultLimitFSIZESoft DefaultLimitDATA DefaultLimitDATASoft DefaultLimitSTACK DefaultLimitSTACKSoft DefaultLimitCORE DefaultLimitCORESoft DefaultLimitRSS DefaultLimitRSSSoft DefaultLimitNOFILE DefaultLimitNOFILESoft DefaultLimitAS DefaultLimitASSoft DefaultLimitNPROC DefaultLimitNPROCSoft DefaultLimitMEMLOCK DefaultLimitMEMLOCKSoft DefaultLimitLOCKS DefaultLimitLOCKSSoft DefaultLimitSIGPENDING DefaultLimitSIGPENDINGSoft DefaultLimitMSGQUEUE DefaultLimitMSGQUEUESoft DefaultLimitNICE DefaultLimitNICESoft DefaultLimitRTPRIO DefaultLimitRTPRIOSoft DefaultLimitRTTIME DefaultLimitRTTIMESoft DefaultTasksMax NNames NFailedUnits NJobs NInstalledJobs NFailedJobs DefaultStartLimitBurst SoftRebootsCount DefaultOOMScoreAdjust ]
    floats: [ Progress ]
    binary: [ InvocationID EffectiveCPUs AllowedCPUs StartupAllowedCPUs AllowedMemoryNodes StartupAllowedMemoryNodes RootHash RootHashSignature CPUAffinity NUMAMask StandardInputData ]
}

export def 'typed-columns' [] {
    $show_columns
}

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
    stl-env {
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
    stl-env {
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

def "inner-show" [name: list<string>, user: bool] {
    do-sysctl $user show --no-pager -- ...$name
        | split row ((char newline) + (char newline))
        | par-each {
            lines | split column '=' -n 2 
            | table-to-record column1 column2 
            | convert-show
            | upsert "Context" (if $user { "user" } else { "system" })
            | upsert "Unit" {|x| $x | get Names? | get 0? }
        }
}

export def "show" [
    unit: string@autocomplete-any,
    --user(-u), 
    --context(-c): string # derive where to took from context
] {
    stl-env {
        if ($user and ($context | is-not-empty)) {
            error make { msg: "Cannot combine user and context" }
        }
        let is_user = $user or ($context == "user")
        let unit_name = get-best-match $unit $is_user
        if ($unit_name | is-empty) {
            error make { msg: "Unit not found" }
        }
        inner-show [ $unit_name ] $is_user | get 0
    }
}

export def "manager" [] {
    stl-env {
        inner-show [] false
    }
}

export def "show-table" [] {
    let units = $in
    stl-env {
        let columns = $units | columns
        if (("unit" not-in $columns) or ("context" not-in $columns)) {
            error make { msg: "Missing unit or context in record" }
        }
        let grouped = $units | group-by context
        # There's a weird manager object
        let systemunits = $grouped | get system? | get unit?
        let userunits = $grouped | get system? | get unit?
        let system = if ($systemunits | is-empty) {
            # Or else we will get the *manager*
            []
        } else {
            inner-show $systemunits false
        }

        let user = if ($userunits | is-empty) {
            # Or else we will get the *manager*
            []
        } else {
            inner-show $systemunits true
        }
        let user = inner-show ([] | append ($grouped | get user? | get unit?)) true
        $user | append $system
    }
}

# Converts systemd duration strings into something nushell can parse.
# This probably still has issues and will need to be added to.
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

# Utility function to check common systemctl "null" formats
# if it's not null, run the closure
def "null-if-infinity" [else: closure] {
    if ($in == "infinity") {
        return null
    }
    if ($in == "[not set]") {
        return null
    }
    if ($in == "n/a") {
        return null
    }
    if ($in == "[no data]") {
        return null
    }
    do $else $in
}

# Utility function to parse show result
def "convert-show" [] {
    # This function really sucks because there is no type information with the show command
    mut details = $in

    # Columns that should be converted to timestamps
    let timestamps = $show_columns | get timestamps

    # Columns that should be converted to file sizes
    let filesizes = $show_columns | get filesizes

    # Columns that should be converted to durations
    let durations = $show_columns | get durations

    # Columns are nanoseconds
    let nsec = $show_columns | get nsec

    # Columns that should be converted to space separated lists
    let simple_lists = $show_columns | get simple_lists

    # Columns that are integers
    let ints = $show_columns | get ints

    let bools = $show_columns | get bools

    let binary = $show_columns | get binary

    let floats = $show_columns | get floats

    for col in $timestamps {
        if (($col in $details) and ($details | get $col | is-not-empty)) {
            # The weird str split and drop is to remove timezone. nushell
            # displays an error, and as far as I can tell you can't remove the message
            $details = $details | update $col { split row ' ' | drop 1 | str join ' ' | into datetime }
        }
    }

    for col in $filesizes {
        if (($col in $details) and ($details | get $col | is-not-empty)) {
            $details = $details | update $col { null-if-infinity {|x| $x | into filesize }}
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

    for col in $floats {
        if (($col in $details) and ($details | get $col | is-not-empty)) {
            $details = $details | update $col { null-if-infinity {|x| $x | into float } }
        }
    }

    for col in $bools {
        if (($col in $details) and ($details | get $col | is-not-empty)) {
            $details = $details | update $col { $in == "yes" }
        }
    }

    for col in $binary {
        if (($col in $details) and ($details | get $col | is-not-empty)) {
            $details = $details | update $col { null-if-infinity {|x| $x | into binary } }
        }
    }

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

# Display current status of a unit. 
#
# This is a condensed version of `show`
export def "status" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
] {
    stl-env {
        if ($user and ($context | is-not-empty)) {
            error make { msg: "Cannot combine user and context" }
        }
        let is_user = $user or ($context == "user")
        let unit_name = get-best-match $unit $is_user
        if ($unit_name | is-empty) {
            error make { msg: "Unit not found" }
        }
        inner-show [ $unit_name ] $is_user | select --ignore-errors ...[
            ActiveState SubState LoadState Names Description Type Restart MainPID NRestarts 
            ExecMainStartTimestamp StateChangeTimestamp MemoryCurrent MemoryPeak MemorySwapCurrent MemorySwapPeak 
            CPUUsageNSec LoadState IOReadBytes IOWriteBytes
        ]
    }
}

def "inner-list-sockets" [user: bool] {
    do-sysctl $user list-sockets --no-pager -o json | from json
}

export def "list-sockets" [
    --user(-u),
    --all(-a)
] {
    stl-env {
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
}

def "inner-list-paths" [user: bool] {
    do-sysctl $user list-paths --no-pager -o json | from json
}

export def "list-paths" [
    --user(-u),
    --all(-a)
] {
    stl-env {
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
}

def "inner-list-jobs" [user: bool] {
    do-sysctl $user list-jobs --no-pager -o json | from json
}

export def "list-jobs" [
    --user(-u),
    --all(-a)
] {
    stl-env {
        if ($all and $user) {
            error make { msg: "Cannot combine user and all" }
        }
        if ($all) {
            let user = inner-list-jobs true | insert context "user"
            let system = inner-list-jobs false | insert context "system"
            return ($system | append $user)
        }
        inner-list-job $user | insert context (if $user { "user" } else { "system" })
    }
}

def "inner-list-automounts" [user: bool] {
    do-sysctl $user list-automounts --no-pager -o json | from json
}

export def "list-automounts" [
    --user(-u),
    --all(-a)
] {
    stl-env {
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
}

export def "logs" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
    --lines(-l): int = 50
] {
    stl-env {
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
        $content | split column ': ' -n 2 
            | update column1 { split column $" ($hostname) " time context 
            | update time { into datetime } } | flatten | flatten | rename time context message
    }
}

# Utility function to see if there is a current sudo session
def "check-sudo" [] {
    (do { sudo -vn } | complete | get exit_code) == 0
}

# Utility function to run an action on a unit, prompting for sudo if needed
def "run-action" [action: string, unit: string, user: bool, sudo_anyways: bool, context?: string] {
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
        systemctl --user $action -- $unit_name
    } else {
        sudo systemctl $action -- $unit_name
    }
}

export def "restart" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
    --sudo-anyways(-s) # prompt for sudo if it makes sense, not prompting if there's a cached session
] {
    stl-env {
        run-action "restart" $unit $user $sudo_anyways $context
    }
}

export def "start" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
    --sudo-anyways(-s) # prompt for sudo if it makes sense, not prompting if there's a cached session
] {
    stl-env {
        run-action "start" $unit $user $sudo_anyways $context
    }
}

export def "stop" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
    --sudo-anyways(-s) # prompt for sudo if it makes sense, not prompting if there's a cached session
] {
    stl-env {
        run-action "stop" $unit $user $sudo_anyways $context
    }
}

export def "reload" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
    --sudo-anyways(-s) # prompt for sudo if it makes sense, not prompting if there's a cached session
] {
    stl-env {
        run-action "reload" $unit $user $sudo_anyways $context
    }
}

export def "freeze" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
    --sudo-anyways(-s) # prompt for sudo if it makes sense, not prompting if there's a cached session
] {
    stl-env {
        run-action "freeze" $unit $user $sudo_anyways $context
    }
}

export def "thaw" [
    unit: string@autocomplete-any, 
    --user(-u), 
    --context(-c): string # derive where to took from context
    --sudo-anyways(-s) # prompt for sudo if it makes sense, not prompting if there's a cached session
] {
    stl-env {
        run-action "thaw" $unit $user $sudo_anyways $context
    }
}

export def "quick-restart" [] {
    try { plugin use skim }
    list-units -a | where type == service | sk --format { get unit } --preview { get description } | restart $in.unit -c $in.context
}

export def "quick-select" [] {
    try { plugin use skim }
    list-units -a | where type == service | sk --format { get unit } --preview { get description }
}

