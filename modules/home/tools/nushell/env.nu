$env.PROMPT_INDICATOR = {|| "> " }

$env.PROMPT_INDICATOR_VI_INSERT = "› "
$env.PROMPT_INDICATOR_VI_NORMAL = "〉"
$env.PROMPT_MULTILINE_INDICATOR = {|| "::: " }

$env.TRANSIENT_PROMPT_COMMAND = {|| ($"(ansi black)›› ")}
$env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
$env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
$env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
$env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'use'),
    ($nu.default-config-dir | path join 'lib'),
    ($nu.default-config-dir | path join 'scripts'),
    ($nu.default-config-dir | path join 'completions'),
]

# Directories to search for plugin binaries when calling register
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins'),
]

# let path_prepend = [
    # "/home/darkkronicle/.local/bin", 
    # "/home/darkkronicle/.local/share/bob/nvim-bin", 
    # "/home/darkkronicle/.local/share/fnm"
# ]

# let path_append = [
    # "/home/darkkronicle/.cargo/bin", 
    # "/home/darkkronicle/Applications",
    # "/usr/local/go/bin", 
    # "/home/darkkronicle/go/bin",
    # "/home/darkkronicle/.node/bin",
# ]

# $env.PATH = ($path_prepend | append ($env.PATH | split row (char esep)) | append $path_append)

$env.FZF_DEFAULT_COMMAND = ("fd . " + $env.HOME)
$env.FZF_CTRL_T_COMMAND= $env.FZF_DEFAULT_COMMAND
$env.FZF_ALT_C_COMMAND = ("fd -t d . " + $env.HOME)

$env.GPG_TTY = (tty)
$env.MANROFFOPT = "-c"

