{ lib, ... }:
{
  importYAML =
    pkgs: file:
    builtins.fromJSON (
      builtins.readFile (
        pkgs.runCommandNoCC "converted-yaml.json" { } ''${pkgs.yj}/bin/yj < "${file}" > "$out"''
      )
    );
  miniJSON =
    pkgs: file:
    builtins.readFile (
      pkgs.runCommandNoCC "converted-minijson.json" { }
        ''${pkgs.nushell}/bin/nu -c "open ${file} --raw | from json | to json --raw" > $out''
    );
}
