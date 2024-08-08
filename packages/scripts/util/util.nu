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
