{
  config,
  lib,
  mylib,
  pkgs,
  mypkgs,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;

  cfg = config.nazarick.workspace.gui.fonts;
in
{
  options.nazarick.workspace.gui.fonts = {
    enable = mkBoolOpt false "Setup default fonts";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = (with mypkgs; [ operator-caska ]) ++ (with pkgs; [ font-manager ]);
    fonts = {
      packages = with pkgs; [
        (nerdfonts.override {
          fonts = [
            "CascadiaCode"
            "IosevkaTerm"
          ];
        })
        inter
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        roboto
        fraunces
        material-symbols
        recursive
        vistafonts # Windows stuff
        twitter-color-emoji
        mypkgs.operator-caska
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
