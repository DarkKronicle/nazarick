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
  package-args = genSpecialArgs {
    system = "x86_64-linux";
    pkgsChannel = inputs.nixpkgs;
    fakeSecrets = true;
    variables = { };
  };
  outputs = {
    nixosConfigurations = lib.attrsets.mergeAttrsList (
      map (it: it.nixosConfigurations or { }) dataWithoutPaths
    );
    packages =
      (lib.attrsets.mergeAttrsList (map (it: it.packages or { }) dataWithoutPaths))
      // (import ../../packages (package-args // args // { pkgs = package-args.pkgs-unstable; }));
  };
in
outputs
