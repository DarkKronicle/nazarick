export extern "nvim" [
    -d, # diff mode
    -u, # use this config file
    --help(-h), # show help
    -n, # no swap file
    -R, # read only
    --clean, # factory defaults
    ...files: path,
]
