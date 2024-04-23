def main [faerber: path, out: path, input: path, ...stores: path] {
  let dir = ([ $out "share" "wallpapers" ] | path join)
  mkdir $dir
  let data = (open $input)
  for wallpaper in $data {
    let name = $wallpaper.src.name
    let found_path = ($stores | find $name)
    if ($found_path | is-empty) {
      print $"Couldn't find ($name)"
      continue
    }
    # Only complaint about nushell so far is for some reason ansi isn't stripped by default
    # This makes it really annoying sometimes if you don't know what you're looking for :(
    let path = ($found_path | get 0| ansi strip)
    # Column exists
    if ($wallpaper | columns | find "themes" | is-not-empty) {
      if ($wallpaper.themes | find "none" | is-not-empty) {
        cp $path ([$dir $wallpaper.src.name] | path join)
      }
      if ($wallpaper.themes | find "mocha" | is-not-empty) {
        let output = ([$dir ("mocha-" + $wallpaper.src.name)] | path join)
        ^$faerber $path $output --flavour mocha --verbose
      }
    } else {
        cp $path ([$dir $wallpaper.src.name] | path join)
    }
  }
}
