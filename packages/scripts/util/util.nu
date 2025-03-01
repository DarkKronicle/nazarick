def util-env [code: closure] {
    with-env {
        PATH: ($env.PATH | prepend @NIX_PATH_PREPEND@)
    } {
        do $code
    }
}

export def follow-which [] {
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
    --amount(-a): int = 10,
    --poll(-p): int = 10,
    --sleep(-s): duration = 0.25sec,
] {
    let realpoll = $poll - 1
    if ($realpoll > 0) {
        print $"Polling ($poll) times over about ($poll * $sleep)..."
    }
    1..($realpoll) | each { |x|
        if ($x != ($realpoll)) {
            sleep $sleep; 
        }
        ps | sort-by -r "cpu" | where $it.pid != $nu.pid | first $amount
    } | flatten | group-by pid | transpose pid info | update info { |x|
    let info = $x | get info
    $info | first 
        # Update and average each column
        | update cpu { ($info.cpu | math sum) / $poll  }
        | update mem { ($info.mem | math sum) / $poll  }
        | update virtual { ($info.virtual | math sum) / $poll  }
        | update name { $info.name | uniq } | reject pid
    } | flatten | sort-by -r "cpu"
}


# https://discord.com/channels/601130461678272522/615253963645911060/1299204614498816040
# Creates a tree of processes from the ps command.
#
# Any table can be piped in, so long as every row has a `pid` and `ppid` column.
# If there is no input, then the standard `ps` is invoked.
export def "ps-tree" [
  --root-pids (-p): list<int> # root of process tree
]: [
  table -> table,
] {
  mut procs = $in

  # get a snapshot to use to build the whole tree as it was at the time of this call
  if $procs == null {
    $procs = ps
  }

  let procs = $procs

  let roots = if $root_pids == null {
    $procs | where ppid? == null or ppid not-in $procs.pid
  } else {
    $procs | where pid in $root_pids
  }

  $roots
  | insert children {|proc|
    $procs
    | where ppid == $proc.pid
    | each {|child|
      $procs
      | ps-tree -p [$child.pid]
      | get 0
    }
  }
}

export def "quick-compress" [--in-type: string = "png", --quality(-q) = 85] {
    let image = $in
    util-env {
        let orig_fs = $image | bytes length | into filesize
        let final = $image | magick $"($in_type):-" -sampling-factor 4:2:0 -strip -quality $"($quality)%" jpg:-
        let final_fs = $final | bytes length | into filesize
        print $"Original: ($orig_fs) - Final: ($final_fs)"
        return $final
    }
}

export def --wrapped "yt-down" [url: string, --help(-h), --audio-only(-x), --video-size: int = 1080, --archive(-a): path, --keep-annoyances(-k), ...rest] {
    if ($help) {
        return (help yt-down);
    }
    mut extra = []
    if ($archive | is-not-empty) {
        $extra = ($extra | append [ "--download-archive" $archive ])
    }
    if (not $keep_annoyances) {
        $extra = ($extra | append [ "--sponsorblock-remove" "sponsor,preview,interaction" ])
    }
    let name = if (not $audio_only) {
        (yt-dlp $url 
            -f $"bestvideo[height<=?($video_size)]+bestaudio/bestvideo[height<=?($video_size)]*+bestaudio/best"
            --write-subs --sub-langs 'en.*,ja' --write-auto-subs --embed-subs 
            --add-metadata
            --embed-metadata 
            --sponsorblock-mark all 
            --compat-options no-keep-subs 
            --convert-subs srt 
            --merge-output-format mkv
            --remux-video mkv 
            --print "after_move:%(filepath)s" 
            --no-simulate 
            --color always 
            --quiet --progress 
            --restrict-filenames
            --no-overwrites
            ...$extra
            ...$rest
            | tee { print }
        )
    } else {
        (yt-dlp $url
            -x
            -f bestaudio
            --print "after_move:%(filepath)s" 
            --no-simulate 
            --color always
            --quiet --progress
            --restrict-filenames
            --no-overwrites
            ...$extra
            ...$rest
            | tee { print }
        )
    }
    return ($name | split row (ansi erase_line) | last | str trim)
}
