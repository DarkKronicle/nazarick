export def follow-which []: {
    $in | follow-symlink-chain $in.path.0
}

  # Credit https://github.com/amtoine
  # https://discord.com/channels/601130461678272522/615253963645911060/1267171213718061167
export def follow-symlink-chain [file: path]: [ nothing -> list<path> ] {
    if not ($file | path exists) {
        error make {
            msg: $"(ansi red_bold)no_such_file(ansi reset)",
            label: {
                text: "no such file",
                span: (metadata $file).span,
            },
        }
    }

    generate { |link|
        let out = { out: $link }

        let res = ls -lD $link
        if ($res | length) == 0 {
            error make --unspanned {
                msg: $"(ansi red_bold)internal error(ansi reset): no files to list at ($link)"
            }
        } else if ($res | length) > 1 {
            return $out
        }

        let target = $res.0.target
        if ($target | is-empty) {
            return $out
        }

        # the target might be relative to the symlink
        let is_relative = $target | path parse | get parent | is-empty
        let next = if $is_relative {
            # recover the absolute path
            $link | path dirname | path join $target
        } else {
            $target
        }

        $out | insert next $next
    } ($file | path expand --no-symlink)
}

export def "sys-usage" [
    sort: string = "cpu",
    --amount(-a): int = 10,
    --poll(-p): int = 10,
    --sleep(-s): duration = 0.25sec,
] {
    let realpoll = $poll - 1
    if ($realpoll > 0) {
        print $"Polling ($poll) times over about ($poll * $sleep)..."
    }
    0..($realpoll) | each { |x|
        if ($x != ($realpoll)) {
            sleep $sleep; 
        }
        ps | sort-by -r $sort | where $it.pid != $nu.pid | first $amount
    } | flatten | group-by pid | transpose pid info | update info { |x|
    let info = $x | get info
    $info | first 
        # Update and average each column
        | update cpu { ($info.cpu | math sum) / $poll  }
        | update mem { ($info.mem | math sum) / $poll  }
        | update virtual { ($info.virtual | math sum) / $poll  }
        | update name { $info.name | uniq } | reject pid
    } | flatten | sort-by -r $sort
}

