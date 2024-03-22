{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.nazarick;
let
  cfg = config.nazarick.appearance.plasma;
in
{
  options.nazarick.appearance.plasma = with types; {
    enable = mkBoolOpt false "Setup Plasma packages";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fluent-icon-theme
      (kdePackages.callPackage ./lightly-qt6.nix { })
      (catppuccin-kde.override {
        flavour = [ "mocha" ];
        accents = [ "mauve" ];
      })
    ];
  };
}
