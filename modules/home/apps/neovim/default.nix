{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  cfg = config.nazarick.apps.neovim;
in
{
  options.nazarick.apps.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {

  };
}
