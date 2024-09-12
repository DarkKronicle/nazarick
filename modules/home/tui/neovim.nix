{
  lib,
  mylib,
  config,
  pkgs,
  inputs,
  system,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.tui.neovim;
in
{
  options.nazarick.tui.neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
    home.sessionVariables.EDITOR = "nvim-cats";

    home.packages = [ inputs.nvim-cats.packages.${system}.nvim-cats ];
  };
}
