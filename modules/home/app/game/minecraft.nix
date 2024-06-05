{
  lib,
  config,
  pkgs,
  inputs,
  mylib,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.app.game.minecraft;
in
{
  options.nazarick.app.game.minecraft = {
    enable = mkEnableOption "Minecraft";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ prismlauncher ]; };
}
