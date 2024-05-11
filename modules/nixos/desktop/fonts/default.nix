{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (lib.nazarick) mkBoolOpt;

  cfg = config.nazarick.desktop.fonts;
in
{
  options.nazarick.desktop.fonts = {
    enable = mkBoolOpt false "Setup default fonts";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ nazarick.operator-caska ];
    fonts = {
      packages = with pkgs; [
        (nerdfonts.override { fonts = [ "CascadiaCode" ]; })
        inter
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        roboto
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [
            "CaskaydiaCove Nerd Font"
            "Noto Color Emoji"
          ];
          sansSerif = [
            "Inter"
            "Noto Color Emoji"
            "Noto Sans CJK JP"
          ];
          serif = [
            "Noto Serif"
            "Noto Color Emoji"
            "Noto Serif CJK JP"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}
