# active
# all
# blocked
# blocking
# burndown.daily
# burndown.monthly
# burndown.weekly
# completed
# ghistory.annual
# ghistory.monthly
# history.annual
# history.monthly
# information
# list
# long
# ls
# minimal
# newest
# oldest
# overdue
# projects
# ready
# recurring
# summary
# tags
# unblocked
# waiting

# https://github.com/nushell/nushell/issues/12289#issuecomment-2075832247
def "date from-record" [] {
    let date_string = ($"($in.year)-($in.month)-($in.day) ($in.hour):($in.minute):($in.second)")
    $date_string | into datetime
}

def or-val [default: any] {
    let val = $in
    if ($in == null) {
        return $default
    }
    return $in
}

def tk-env [code: closure] {
    with-env {
        PATH: ($env.PATH | prepend @NIX_PATH_PREPEND@)
    } {
        do $code
    }
}

# https://www.kiils.dk/en/blog/making-taskwarrior-better-with-nushell/

def upsert-val [field, block: closure] {
    $in | upsert $field { |it|
        let value = ($it | get -i $field)
        if ($value == null or ($value | is-empty)) { null } else { $value | do $block $value }
    }
}

def into-list [] {
    let val = $in
    if (($in | describe) =~ "^list") {
        return $val
    }
    return [ $val ]
}

def is-uuid [] {
    # https://stackoverflow.com/questions/136505/searching-for-uuids-in-text-with-regex
    $in =~ "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
}

def get-tasks-uuids [] {
    # Check if uuids
    let input = $in
    let type = $input | describe
    if ($type == "string") {
        if ($input | is-uuid) {
            return $input
        }
        error make { msg: "Input not UUID" }
    }
    if ($type == "list<string>") {
        if ($input | all { is-uuid }) {
            return $input
        }
        error make { msg: "Not a list of UUIDs" }
    }
    if ($type =~ "^list") {
        if ("uuid" in ($input | columns)) {
            if ($input.uuid | all { is-uuid }) {
                return $input.uuid
            }
            error make { msg: "UUID column is invalid" }
        }
    }

    # No UUIDs, check if there are ids anywhere
    let ids = (if (($input | describe) == "list<int>") {
        $input
    } else if (($input | describe) == "int") {
        [ $input ]
    } else {
        ($input | get id)
    } | into-list)
    if (($ids | describe) != "list<int>") {
        error make {msg: "No UUIDs or IDs found"}
    }
    let found = (show ($ids | str join " ") | get uuid)
    if (($found | length) != ($ids | length)) {
        error make {msg: "Couldn't find all UUIDs"}
    }
    return $found
}

def filter-tasks [] {
    $in | where ($it.wait == null or $it.wait < (date now)) | where status == "pending"
}

def "fix-due" [] {
    let task = $in
    let due = $task | get due?
    if ($due == null) {
        return
    }
    let date = $due | date to-timezone (date now | into record | get timezone) | into record
    if ($date.hour > 6 or $date.second != 0 or $date.minute != 0) {
        return
    }
    let iso = $date | upsert hour 23 | upsert minute 59 | upsert second 59 | date from-record | format date "%+"
    $task | modify $"due:($iso)"
}

# Needs a full task object in
def "get-dir" [] {
    let dir = if (($in | get -i dir) != null) {
        $in | get dir
    } else {
        if (($in | get -i project) | is-empty) {
            error make { msg: "Can't get directory for empty project and empty dir " }
        }
        $in | get project | str replace -a "." "/"
    }
    return (["~/Documents/atlas/tasks" $dir ] | path join)
}

# id, description, due, end, entry, modified, priority, project, status, uuid, urgency, scheduled, wait, tags, annotations, depends

# imask, last, mask, parent, recur, rtype, template, until
export def "show" [query?: string, report?: string] {
    let args = [ ($query | default "" | split row " ") export ] | flatten | where $it != null | where ($it | is-not-empty)
    ^task ...$args | from json
        | upsert-val project { $in }
        | upsert-val entry { into datetime }
        | upsert-val modified { into datetime }
        | upsert-val end { into datetime }
        | upsert-val due { into datetime }
        | upsert-val wait { into datetime }
        | upsert-val scheduled { into datetime }
        | upsert-val annotations {|x| $x | upsert entry { into datetime }}
        | upsert-val tags { $in }
        | upsert-val area { $in }
        | upsert-val type { $in }
        | upsert-val brain { $in }
        | upsert-val dir { $in }
}

export def "group" [--depth(-d): int = 1, --key: string = "project", --split: closure, --join: closure] {
    let $split = $split | or-val { split row "." }
    let $join = $join | or-val { str join "." }
    $in | group-by {|x| 
        let inter = $x | get -i $key
        if ($inter != null) {
            $inter | do $split $in | first $depth | do $join $in
        } else {
            ""
        }
    } --to-table | rename $key tasks
}

export def "group-recursive" [--key: string = "project", --split: closure, --join: closure] {
    let $split = $split | or-val { split row "." }
    let $join = $join | or-val { str join "." }
    let data = $in
    let max = $in | get project | where ($it != null) | par-each { do $split $in | length } | math max
    $max..1 | reduce -f $data {|it, acc| $acc | group -d $it --split $split --join $join }
}

export def "display" [] {
    $in | upsert ref {|x| $x | get project? | default ($x | get area?) } | select -i id due description ref urgency status tags | upsert-val tags { str join "," } | update due { date to-timezone (date now | into record | get timezone) }
}

export def "detailed" [] {
    let tasks = show ($in | get-tasks-uuids | str join " ") | reject uuid
    if (($tasks | length) == 1) {
        return ($tasks | into record)
    }
    return $tasks
}

export def --wrapped "raw-add" [...statement: string] {
    ^task add ...$statement
    sleep 0.1sec
    show "+LATEST" | get 0 | fix-due
}

export def --wrapped "add" [
    tags: list<string>
    --due(-d): any = null, 
    --wait(-w): any = null, 
    --type(-t): any = "act"
    ...statement: string
] {
    mut extra_args = []
    if ($due != null) {
        let realdue = (if (($due | describe) == "date") {
            $due
        } else {
            $due | into datetime
        }) | format date "%+"
        $extra_args = ($extra_args | append [ $"due:($realdue)" ])
    }
    if ($wait != null) {
        let realdue = (if (($wait | describe) == "date") {
            $wait
        } else {
            $wait | into datetime
        }) | format date "%+"
        $extra_args = ($extra_args | append [ $"wait:($realdue)" ])
    }
    if ($type != null) {
        $extra_args = ($extra_args | append [ $"type:($type)" ])
    }
    if ($tags | is-not-empty) {
        $extra_args = ($extra_args | append ($tags | par-each { |x| $"+($x)" }))
    }
    raw-add ...$statement ...$extra_args
}

export def --wrapped "raw-modify" [...statement: string] {
    let tasks = $in | get-tasks-uuids
    ^task ($tasks | str join " ") modify ...$statement
    show "+LATEST" | get 0 | fix-due
}

export def --wrapped "modify" [
    --due(-d): any = null, 
    --wait(-w): any = null, 
    ...statement: string
] {
    let tasks = $in
    mut extra_args = []
    if ($due != null) {
        let realdue = (if (($due | describe) == "date") {
            $due
        } else {
            $due | into datetime
        }) | format date "%+"
        $extra_args = ($extra_args | append [ $"due:($realdue)" ])
    }
    if ($wait != null) {
        let realdue = (if (($wait | describe) == "date") {
            $wait
        } else {
            $wait | into datetime
        }) | format date "%+"
        $extra_args = ($extra_args | append [ $"wait:($realdue)" ])
    }
    $tasks | raw-modify ...$statement ...$extra_args
}

export def "done" [] {
    ^task ($in | get-tasks-uuids | str join " ") done
}

export def "delete" [] {
    ^task ($in | get-tasks-uuids | str join " ") delete
}

export def "main" [query?: string] {
    let default = $query == null
    let $query = $query | or-val "status:pending type:act"
    let result = show $query | filter-tasks
    if ($default) {
        return ($result | display | reject status | sort-by -r urgency)
    }
    $result | display | sort-by -r urgency
}

export def "undo" [] {
    ^task undo
}

export def "in" [...statement: string] {
    if ($statement | is-empty) {
        return (show "status:pending type:in" | upsert-val tags { filter { $in not-in [ "in" ] } } | display)
    }
}

export def "choose" [] {
    let uuids = $in | get-tasks-uuids

    show ($uuids | str join " ") | sk --format { get description } --preview { sort } -m
}

export def "dir" [] {
    let uuids = $in | get-tasks-uuids
    if (($uuids | length) != 1) {
        error make { msg: "Can't get dir multiple task notes at once" }
    }
    return (show ($uuids | get 0) | get 0 | get-dir)
}


export def --env "goto" [
    -D, # Do not create directory
] {
    let dir = $in | dir
    if (not $D) {
        mkdir $dir
    }
    cd $dir
}

export def --env "overlay" [] {
    overlay new test
}
