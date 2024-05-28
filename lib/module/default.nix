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

  # https://github.com/nix-community/home-manager/blob/10c7c219b7dae5795fb67f465a0d86cbe29f25fa/modules/programs/nushell.nix#L14C3-L41C1
  linesOrSource =
    let
      inherit (lib) types mkOption literalExpression;
    in
    types.submodule (
      { config, ... }:
      {
        options = {
          text = lib.mkOption {
            type = types.lines;
            default = if config.source != null then builtins.readFile config.source else "";
            defaultText = literalExpression "if source is defined, the content of source, otherwise empty";
            description = ''
              Text of the file.
              If unset then the source option will be preferred.
            '';
          };

          source = mkOption {
            type = types.nullOr types.path;
            default = null;
            description = ''
              Path of the nushell file to use.
              If the text option is set, it will be preferred.
            '';
          };
        };
      }
    );
}
