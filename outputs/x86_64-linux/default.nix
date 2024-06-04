{
  lib,
  inputs,
  genSpecialArgs,
  ...
}@args:
let
  inherit (inputs) haumea;
  data = haumea.lib.load {
    src = ./src;
    inputs = args;
  };
  dataWithoutPaths = builtins.attrValues data;
  package-args = genSpecialArgs "x86_64-linux" inputs.nixpkgs true;
  outputs = {
    nixosConfigurations = lib.attrsets.mergeAttrsList (
      map (it: it.nixosConfigurations or { }) dataWithoutPaths
    );
    packages =
      (lib.attrsets.mergeAttrsList (map (it: it.packages or { }) dataWithoutPaths))
      // (import ../../packages (package-args // args // { pkgs = package-args.pkgs-stable; }));
  };
in
outputs
