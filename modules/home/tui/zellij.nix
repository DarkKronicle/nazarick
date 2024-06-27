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
    nazarick.cli.nushell.alias = {
      "zel" = "zellij -l welcome";
    };

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
