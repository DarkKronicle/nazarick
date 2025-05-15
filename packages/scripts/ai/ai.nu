# credit: flovilmart https://discord.com/channels/601130461678272522/988303282931912704/1353796832408502314

def spinner [] {
  while true {
    for i in ["|", "/", "-", "\\"] {
      print -rn $"\r($i)"
      sleep 0.1sec
    }
  }
}

def "start spinner" [] {
  job spawn { spinner }
}

def ai-env [code: closure] {
    with-env {
        PATH: ($env.PATH | prepend @NIX_PATH_PREPEND@)
    } {
        do $code
    }
}

def roles [] { 
    ai-env {
        return (aichat --list-roles | lines)
    }
}

def models [] { 
    ai-env {
        return (aichat --list-models | lines)
    }
}

export def "main" [] {

}

export def "last" [] {
    return $env.__AI_LAST_ANSWER
}


def "ask-inner" [
    query: string,
    --role(-r): string@roles,
    --model(-m): string@models,
    --files(-f): list<path>,
    --urls(-u): list<path>,
    --width(-w): int = 100, # word-wrap at width (set to 0 to disable)
    --no-format(-F), # don't use an app to format the output
    --show-reasoning(-S), # show <think> block
    --code(-c), # try to parse code blocks
] : any -> list<string> {
    let val = $in
    ai-env {
        mut flags = []

        if ($model != null) {
            $flags = $flags | append ["--model" $model]
        }

        if ($role != null) {
            $flags = $flags | append ["--role" $role]
        }

        for $file in $files {
            $flags = $flags | append ["--file" $file]
        }
        
        for $url in $urls {
            # Yes, the file is a url
            $flags = $flags | append ["--file" $url]
        }

        let full_answer = (
            if ($val | is-empty) {
                aichat ...$flags $query
            } else {
                let inner_val = if (($val | describe) == string) {
                    $val
                } else {
                    $val | to json --raw
                }
                $inner_val | aichat ...$flags $query
            }
        )
        mut answer = $full_answer

        # Source
        # https://stackoverflow.com/questions/76269934/issues-creating-a-regex-to-extract-code-from-markdown

        if ($code) {
            return [$full_answer ($answer | str replace -r '(?s)<think>.*?</think>\s+' '' | parse -r '(?sm)^```(?:\w+)?\s*\n(.*?)(?=^```)```' | get capture0.0 | str trim)]
        }

        if (not $show_reasoning) {
            $answer = $answer | str replace -r '(?s)<think>.*?</think>\s+' ''
        }

        if ($no_format) {
            return [$full_answer $answer]
        }
        let answer = $answer
        let rendered = $answer | rich - --markdown --force-terminal
        return [$full_answer $rendered]
    }
}

export def --env "ask" [
    query: string,
    --role(-r): string@roles,
    --model(-m): string@models,
    --files(-f): list<path>,
    --urls(-u): list<path>,
    --width(-w): int = 100, # word-wrap at width (set to 0 to disable)
    --no-format(-F), # don't use an application to format the output (no text will be returned if you don't use this or code)
    --show-reasoning(-S), # show <think> block
    --code(-c), # try to parse code blocks
] : any -> string {
    let val = $in
    let spinner = (start spinner)
    try {
        let answers = (
            $val | ask-inner $query --role=$role --model=$model 
            --files=$files --urls=$urls --width=$width
            --no-format=$no_format --show-reasoning=$show_reasoning
            --code=$code
        )

        $env.__AI_LAST_ANSWER = ($answers | get 0)

        try {
            job kill $spinner
        }
        print -rn "\r\e[2K"
        print -rn " "
        return ($answers | get 1)
    } catch { |err|
        try {
            job kill $spinner
        }
        error make ($err | get json | from json)
    }

}
