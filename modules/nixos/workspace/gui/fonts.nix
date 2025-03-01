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
    environment.systemPackages = with pkgs; [ font-manager ];
    fonts = {
      packages = with pkgs; [
        nerd-fonts.caskaydia-cove
        nerd-fonts.fantasque-sans-mono
        nerd-fonts.cousine
        nerd-fonts.comic-shanns-mono
        nerd-fonts.fira-code
        nerd-fonts.go-mono
        nerd-fonts.hack
        nerd-fonts.jetbrains-mono
        nerd-fonts.monaspace
        nerd-fonts.monofur
        nerd-fonts.noto
        nerd-fonts.tinos
        nerd-fonts.ubuntu-sans
        inter
        noto-fonts
        noto-fonts-emoji
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        roboto
        fraunces
        material-symbols
        recursive
        vistafonts # Windows stuff
        twitter-color-emoji
        azeret-mono
        overpass
        victor-mono
        paratype-pt-mono
        paratype-pt-sans
        paratype-pt-serif
        monaspace
        cascadia-code

        corefonts
        vistafonts

        atkinson-hyperlegible
        atkinson-monolegible
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
