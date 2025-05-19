# A wrapper for aichat with easy switching for models, rags, and roles
#
# I'm still working on the ethics of AI use and thought this was a good middle ground.
# I'll probably write a blog post, but to keep me straight:
# - I think it can be a really useful tool
# - there are big ethical concerns with copyright, power, climate change
# - issues of creative works going out
# - issues of bias
# - issues of privacy
# - there's political concerns with what using AI supports. Big startups with little regard for certain
#   things. You have long-termism beliefs that want "AI to advance regardless of consequences"
#
# For me, I don't want to use AI (LLMs+) to replace human creativity. I'm going to treat it as a tool
# that is powerful at natural language processing.
#
# For some select complex problems, AI can be really useful. I want AI to mainly synthesize and not create.
#
# For power concerns, I have put a bunch of lower-cost models that I can easily select from aichat.
# I will use these when it makes sense, and will then use together.ai for hosting of larger models.
# The goal is to make it easy to change what I use and have to think *if* what I am doing should
# use a 100B parameter model.
#
# More reading: 
# - https://hidde.blog/ethical-ai/
# - https://www.youtube.com/watch?v=F4KQ8wBt1Qg

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

def rags [] { 
    ai-env {
        return (aichat --list-rags | lines)
    }
}

export def "main" [] {

}

export def "last" [] {
    return $env.__AI_LAST_ANSWER
}


def "ask-inner" [
    spinner: int,
    query?: string,
    --role(-r): string@roles,
    --model(-m): string@models,
    --rag(-g): string@rags,
    --files(-f): list<path>,
    --urls(-u): list<path>,
    --width(-w): int = 100, # word-wrap at width (set to 0 to disable)
    --no-format(-F), # don't use an app to format the output
    --show-reasoning(-S), # show <think> block
    --code(-c), # try to parse code blocks
    --no-stream(-s), # never stream
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

        if ($no_stream or ($query == null)) {
            $flags = $flags | append ("--no-stream")
        }

        if ($rag != null) {
            $flags = $flags | append ["--rag" $rag]
        }

        for $file in $files {
            $flags = $flags | append ["--file" $file]
        }
        
        for $url in $urls {
            # Yes, the file is a url
            $flags = $flags | append ["--file" $url]
        }

        if ($query == null) {
            job kill $spinner
            $flags = $flags | append ["--session" (random chars --length 5)]
            if ($val | is-empty) {
                aichat ...$flags
            } else {
                let inner_val = if (($val | describe) == string) {
                    $val
                } else {
                    $val | to json --raw
                }
                $inner_val | aichat ...$flags
            }
            return ["" ""]
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
            return [$full_answer ($answer | str replace -r '^(?s).*?<think>.*?</think>\s+' '' | parse -r '(?sm)^```(?:\w+)?\s*\n(.*?)(?=^```)```' | get capture0.0 | str trim)]
        }

        if (not $show_reasoning) {
            $answer = $answer | str replace -r '^(?s).*?<think>.*?</think>\s+' ''
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
    query?: string,
    --role(-r): string@roles,
    --model(-m): string@models,
    --rag(-g): string@rags,
    --files(-f): list<path>,
    --urls(-u): list<path>,
    --width(-w): int = 100, # word-wrap at width (set to 0 to disable)
    --no-format(-F), # don't use an application to format the output (no text will be returned if you don't use this or code)
    --show-reasoning(-S), # show <think> block
    --code(-c), # try to parse code blocks
    --no-stream(-s), # never stream
] : any -> string {
    let val = $in
    let spinner = (start spinner)
    try {
        let answers = (
            $val | ask-inner $spinner $query --role=$role --model=$model 
            --files=$files --urls=$urls --width=$width
            --no-format=$no_format --show-reasoning=$show_reasoning
            --code=$code --rag=$rag
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
