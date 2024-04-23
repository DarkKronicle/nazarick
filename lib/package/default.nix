{ lib, ... }:
{
  importYAML =
    pkgs: file:
    builtins.fromJSON (
      builtins.readFile (
        pkgs.runCommandNoCC "converted-yaml.json" { } ''${pkgs.yj}/bin/yj < "${file}" > "$out"''
      )
    );
}
