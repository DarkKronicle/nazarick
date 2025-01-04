use @BLACK_IMORTAL@
use @TASK@

# The default config record. This is where much of your global configuration is setup.
$env.config = {
  # true or false to enable or disable the welcome banner at startup
  show_banner: false
  ls: {
    use_ls_colors: true # use the LS_COLORS environment variable to colorize output
    clickable_links: true # enable or disable clickable links. Your terminal has to support links.
  }

  rm: {
    always_trash: true # always act as if -t was given. Can be overridden with -p
  }
  # cd: {
  #   abbreviations: false # allows `cd s/o/f` to expand to `cd some/other/folder`
  # }
  table: {
    mode: rounded # basic, compact, compact_double, light, thin, with_love, rounded, reinforced, heavy, none, other
    index_mode: always # "always" show indexes, "never" show indexes, "auto" = show indexes when a table has "index" column
    show_empty: true # show 'empty list' and 'empty record' placeholders for command output
    trim: {
      methodology: wrapping # wrapping or truncating
      wrapping_try_keep_words: true # A strategy used by the 'wrapping' methodology
      truncating_suffix: "..." # A suffix used by the 'truncating' methodology
    }
  }

  explore: {
    help_banner: true
    exit_esc: true

    command_bar_text: '#C4C9C6'
    # command_bar: {fg: '#C4C9C6' bg: '#223311' }

    status_bar_background: {fg: '#1D1F21' bg: '#C4C9C6' }
    # status_bar_text: {fg: '#C4C9C6' bg: '#223311' }

    highlight: {bg: 'yellow' fg: 'black' }

    status: {
      # warn: {bg: 'yellow', fg: 'blue'}
      # error: {bg: 'yellow', fg: 'blue'}
      # info: {bg: 'yellow', fg: 'blue'}
    }

    try: {
      # border_color: 'red'
      # highlighted_color: 'blue'

      # reactive: false
    }

    table: {
      split_line: '#404040'

      cursor: true

      line_index: true
      line_shift: true
      line_head_top: true
      line_head_bottom: true

      show_head: true
      show_index: true

      # selected_cell: {fg: 'white', bg: '#777777'}
      # selected_row: {fg: 'yellow', bg: '#C1C2A3'}
      # selected_column: blue

      # padding_column_right: 2
      # padding_column_left: 2

      # padding_index_left: 2
      # padding_index_right: 1
    }

    config: {
      cursor_color: {bg: '#cba6f7' fg: 'black' }

      # border_color: white
      # list_color: green
    }
  }

  history: {
    max_size: 10000 # Session has to be reloaded for this to take effect
    sync_on_enter: true # Enable to share history between multiple sessions, else you have to close the session to write history to file
    file_format: "plaintext" # "sqlite" or "plaintext"
    isolation: false # true enables history isolation, false disables it. true will allow the history to be isolated to the current session. false will allow the history to be shared across all sessions.
  }
  completions: {
    case_sensitive: false # set to true to enable case-sensitive completions
    quick: true  # set this to false to prevent auto-selecting completions when only one remains
    partial: true  # set this to false to prevent partial filling of the prompt
    algorithm: "fuzzy"  # prefix or fuzzy
    external: {
      enable: true # set to false to prevent nushell looking into $env.PATH to find more suggestions, `false` recommended for WSL users as this look up my be very slow
      max_results: 100 # setting it lower can improve completion performance at the cost of omitting some options
      completer: null # check 'carapace_completer' above as an example
    }
  }
  filesize: {
    metric: true # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
    format: "auto" # b, kb, kib, mb, mib, gb, gib, tb, tib, pb, pib, eb, eib, zb, zib, auto
  }
  cursor_shape: {
    emacs: line # block, underscore, line, blink_block, blink_underscore, blink_line (line is the default)
    vi_insert: block # block, underscore, line , blink_block, blink_underscore, blink_line (block is the default)
    vi_normal: underscore # block, underscore, line, blink_block, blink_underscore, blink_line (underscore is the default)
  }
  color_config: (black-metal-immortal)
  footer_mode: 25
  float_precision: 2
  use_ansi_coloring: true
  bracketed_paste: true
  edit_mode: vi
  use_kitty_protocol: (@KITTY_PROTOCOL@ and ("ZELLIJ" not-in ($env | columns))), # enables keyboard enhancement protocol implemented by kitty console, only if your terminal support this.
  shell_integration: {
    osc2: true
    osc7: true
    osc8: true
    osc9_9: false # weird kitty notifications
    osc133: true
    reset_application_mode: true
  }
  render_right_prompt_on_last_line: false

  hooks: {
    display_output: {||
      if (term size).columns >= 100 { table -e } else { table }
    }
    env_change: {
        PWD: []
    }
  }

    menus: [
      {
        name: completion_menu
        only_buffer_difference: false
        marker: "| "
        type: {
            layout: columnar
            columns: 4
            col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
            col_padding: 2
        }
        style: {
            text: "#cdd6f4"
            selected_text: "#cba6f7"
            description_text: "#bac2de"
        }
      }
      {
        name: history_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: "#cdd6f4"
            selected_text: "#cba6f7"
            description_text: "#bac2de"
        }
      }
      {
        name: help_menu
        only_buffer_difference: true
        marker: "? "
        type: {
            layout: description
            columns: 4
            col_width: 20   # Optional value. If missing all the screen width is used to calculate column width
            col_padding: 2
            selection_rows: 4
            description_rows: 10
        }
        style: {
            text: "#cdd6f4"
            selected_text: "#cba6f7"
            description_text: "#bac2de"
        }
      }
    ]

  keybindings: [
    {
      name: yank
      modifier: control
      keycode: char_y
      mode: [ emacs, vi_insert ]
      event: {
        until: [
          {edit: pastecutbufferafter}
        ]
      }
    }
    {
        name: help_menu
        modifier: control
        keycode: "char_/"
        mode: [emacs, vi_insert, vi_normal]
        event: { send: menu name: help_menu }
    }
  ]
}

# $env.EDITOR is of unknown type (for me it will always be nvim),
# but I'm using nixCats, so I want to be able to switch it without
# having to do any more work here. This will just wrap the nvim command for me
# and give me good completions

# Run nvim that is declared in $env.EDITOR
def --env nvim [
    -d: list<path>, # diff mode
    -u: path, # use this config file
    --cmd: string, # run this command before anything
    -c: string, # run this command after first file
    -l: list<string>, # run lua script with args
    -n, # no swap file
    -R, # read only
    --clean, # factory defaults
    ...paths: path
] {
    mut args = [];
    if ($d | is-not-empty) {
        $args = ($args | append "-d" | append $d)
    }
    if ($cmd | is-not-empty) {
        $args = ($args | append "--cmd" | append $cmd)
    }
    if ($c | is-not-empty) {
        $args = ($args | append "-c" | append $c)
    }
    if ($l | is-not-empty) {
        $args = ($args | append "-l" | append $l)
    }
    if ($R) {
        $args = ($args | append "-R")
    }
    if ($n) {
        $args = ($args | append "-n")
    }
    if ($clean) {
        $args = ($args | append "--clean")
    }
    $args = ($args | append $paths)
    ^$env.EDITOR ...$args
}

alias neovim = nvim
alias v = nvim

source ~/.config/nushell/scripts/dolphin.nu
source ~/.config/nushell/completions/tldr.nu

def --env borger [command: closure] {
    do --capture-errors {
        $env.BORG_REPO = (cat /run/secrets/borg/repository)
        $env.BORG_PASSPHRASE = (cat /run/secrets/borg/password)
        do --capture-errors $command
    }
}

plugin use skim

alias tkk = overlay use tk
alias tko = overlay hide tk
