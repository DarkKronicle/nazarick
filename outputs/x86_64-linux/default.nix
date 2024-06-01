{
  lib,
  inputs,
  ...
} @ args: let
  inherit (inputs) haumea;
  data = haumea.lib.load {
    src = ./src;
    inputs = args;
  };
  dataWithoutPaths = builtins.attrValues data;
  outputs = {
    nixosConfigurations = lib.attrsets.mergeAttrsList (map (it: it.nixosConfigurations or {}) dataWithoutPaths);
    packages = lib.attrsets.mergeAttrsList (map (it: it.packages or {}) dataWithoutPaths);
  };
in outputs
