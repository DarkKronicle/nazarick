{
  lib,
  mylib,
  pkgs,
  config,
  ...
}:
let

  cfg = config.nazarick.tui.zellij;

in
{
  options.nazarick.tui.zellij = {
    enable = lib.mkEnableOption "Zellij";
  };

  config = lib.mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      settings = {
        pane_frames = false;
        theme = "catppuccin-mocha";
        copy_on_select = false;

      };
    };
  };
}