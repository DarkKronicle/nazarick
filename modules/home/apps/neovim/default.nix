{
  lib,
  mylib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.apps.neovim;
in
{
  options.nazarick.apps.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    home.sessionVariables.EDITOR = "nvim-cats";

    home.packages = [ inputs.nvim-cats.packages.x86_64-linux.nvim-cats ];
  };
}
