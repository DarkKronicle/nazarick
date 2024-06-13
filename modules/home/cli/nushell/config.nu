use ~/.config/nushell/themes/black-metal-immortal.nu
use ~/.config/nushell/auto-venv.nu auto-venv-toggle
use ~/.config/nushell/task.nu

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
  color_config: (black-metal-immortal)   # if you want a light theme, replace `$dark_theme` to `$light_theme`
  use_grid_icons: true
  footer_mode: "25" # always, never, number_of_rows, auto
  float_precision: 2 # the precision for displaying floats in tables
  # buffer_editor: "emacs" # command that will be used to edit the current line buffer with ctrl+o, if unset fallback to $env.EDITOR and $env.VISUAL
  use_ansi_coloring: true
  bracketed_paste: true # enable bracketed paste, currently useless on windows
  edit_mode: vi # emacs, vi
  use_kitty_protocol: true,
  shell_integration: {
    osc2: true
    osc7: true
    osc8: true
    osc9_9: false # weird kitty notifications
    osc133: true
    reset_application_mode: true
  }
  render_right_prompt_on_last_line: false # true or false to enable or disable right prompt to be rendered on last line of the prompt.

  hooks: {
    pre_prompt: [{||
      null  # replace with source code to run before the prompt is shown
    }]
    pre_execution: [{||
      null  # replace with source code to run before the repl input is run
    }]
    env_change: {
      PWD: [{|before, after| auto-venv-toggle $env }]
    }
    display_output: {||
      if (term size).columns >= 100 { table -e } else { table }
    }
    command_not_found: {||
      null  # replace with source code to return an error message when a command is not found
    }
  }
  menus: [
      # Configuration for default nushell menus
      # Note the lack of source parameter
	  {
        name: fzf_history_menu_fzf_ui
        only_buffer_difference: false
        marker: "# "
        type: {
            layout: list
			page_size: 10
        }
        style: {
            text: "#cdd6f4"
            selected_text: "#cba6f7"
            description_text: "#bac2de"
        }
        source: { |buffer, position|
			history | each { |it| $it.command } | uniq | reverse | 
			str join (char -i 0) | fzf --read0 --height 40% -f $buffer | 
			lines | each { |v| {value: ($v | str trim) } }
        }
      }
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
      # Example of extra menus created using a nushell source
      # Use the source field to create a list of records that populates
      # the menu
      {
        name: commands_menu
        only_buffer_difference: false
        marker: "# "
        type: {
            layout: columnar
            columns: 4
            col_width: 20
            col_padding: 2
        }
        style: {
            text: "#cdd6f4"
            selected_text: "#cba6f7"
            description_text: "#bac2de"
        }
        source: { |buffer, position|
            $nu.scope.commands
            | where name =~ $buffer
            | each { |it| {value: $it.name description: $it.usage} }
        }
      }
      {
        name: vars_menu
        only_buffer_difference: true
        marker: "# "
        type: {
            layout: list
            page_size: 10
        }
        style: {
            text: "#cdd6f4"
            selected_text: "#cba6f7"
            description_text: "#bac2de"
        }
        source: { |buffer, position|
            $nu.scope.vars
            | where name =~ $buffer
            | sort-by name
            | each { |it| {value: $it.name description: $it.type} }
        }
      }
      {
        name: commands_with_description
        only_buffer_difference: true
        marker: "# "
        type: {
            layout: description
            columns: 4
            col_width: 20
            col_padding: 2
            selection_rows: 4
            description_rows: 10
        }
        style: {
            text: "#cdd6f4"
            selected_text: "#cba6f7"
            description_text: "#bac2de"
        }
        source: { |buffer, position|
            $nu.scope.commands
            | where name =~ $buffer
            | each { |it| {value: $it.name description: $it.usage} }
        }
      }
  ]
  keybindings: [
    {
      name: completion_menu
      modifier: none
      keycode: tab
      mode: [emacs vi_normal vi_insert]
      event: {
        until: [
          { send: menu name: completion_menu }
          { send: menunext }
        ]
      }
    }
    {
      name: completion_previous
      modifier: shift
      keycode: backtab
      mode: [emacs, vi_normal, vi_insert] # Note: You can add the same keybinding to all modes by using a list
      event: { send: menuprevious }
    }
	{
	  name: fuzzy_history
	  modifier: control
	  keycode: char_r
	  mode: [emacs, vi_normal, vi_insert]
	  event: { send: menu name: fzf_history_menu_fzf_ui }
	}
	# {
      # name: fuzzy_history
      # modifier: control
      # keycode: char_r
      # mode: [emacs, vi_normal, vi_insert]
      # event: [
        # {
          # send: ExecuteHostCommand
          # cmd: "commandline (
            # history
              # | each { |it| $it.command }
              # | uniq
              # | reverse
              # | str join (char -i 0)
              # | fzf --read0 --layout=reverse +s --height=40% -q (commandline)
              # | decode utf-8
              # | str trim
          # )"
        # }
      # ]
    # }
    {
      name: next_page
      modifier: control
      keycode: char_x
      mode: emacs
      event: { send: menupagenext }
    }
    {
      name: undo_or_previous_page
      modifier: control
      keycode: char_z
      mode: emacs
      event: {
        until: [
          { send: menupageprevious }
          { edit: undo }
        ]
       }
    }
    {
            
      name: yank
      modifier: control
      keycode: char_y
      mode: emacs
      event: {
        until: [
          {edit: pastecutbufferafter}
        ]
      }
    }
    {
      name: unix-line-discard
      modifier: control
      keycode: char_u
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          {edit: cutfromlinestart}
        ]
      }
    }
    {
      name: kill-line
      modifier: control
      keycode: char_k
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          {edit: cuttolineend}
        ]
      }
    }
    # Keybindings used to trigger the user defined menus
    {
      name: commands_menu
      modifier: control
      keycode: char_t
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: commands_menu }
    }
    {
      name: vars_menu
      modifier: alt
      keycode: char_o
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: vars_menu }
    }
    {
      name: commands_with_description
      modifier: control
      keycode: char_s
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menu name: commands_with_description }
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

source ~/.config/nushell/scripts/fuzzy.nu
source ~/.config/nushell/scripts/dolphin.nu
source ~/.config/nushell/completions/man.nu
source ~/.config/nushell/completions/tldr.nu

alias zz = systemd-inhibit sleep infinity

def --env fuck [] {
    let cmd = (history | last 1 | get 0 | get command)
    ^(thefuck $cmd)
}

alias bruh = fuck

alias xt = eza -T -L=3 --icons
alias xi = eza --icons 
alias x = eza --icons -l -b -h --no-user --no-permissions --group-directories-first
alias xm = eza --icons -l -b -h --no-user --no-permissions --group-directories-first --sort modified --reverse

alias icat = kitten icat

def --env borger [command: closure] {
    do --capture-errors {
        $env.BORG_REPO = (cat /run/secrets/borg/repository)
        $env.BORG_PASSPHRASE = (cat /run/secrets/borg/password)
        do --capture-errors $command
    }
}

plugin use explore
alias ex = nu_plugin_explore