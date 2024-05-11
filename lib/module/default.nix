{ lib, ... }:
rec {

  mkOpt =
    type: default: description:
    lib.mkOption { inherit type default description; };

  mkBoolOpt = mkOpt lib.types.bool;

  mkIfElse =
    p: yes: no:
    lib.mkMerge [
      (lib.mkIf p yes)
      (lib.mkIf (!p) no)
    ];

  enabled = {
    enable = true;
  };

  disabled = {
    enable = false;
  };
}
