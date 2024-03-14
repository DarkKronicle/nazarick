{ lib, ... }:
with lib;
rec {

  mkOpt =
    type: default: description:
    mkOption { inherit type default description; };

  mkBoolOpt = mkOpt types.bool;

  mkIfElse =
    p: yes: no:
    mkMerge [
      (mkIf p yes)
      (mkIf (!p) no)
    ];

  enabled = {
    enable = true;
  };

  disabled = {
    enable = false;
  };
}
