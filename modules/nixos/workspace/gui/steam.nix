{
  options,
  config,
  lib,
  mylib,
  pkgs,
  inputs,
  system,
  ...
}:

let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;
  cfg = config.nazarick.workspace.gui.steam;
in
{
  options.nazarick.workspace.gui.steam = {
    enable = mkBoolOpt false "Enable Steam";
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.gamemode.enable = true;
    # This works with xbox controllers. If it can't connect (connection/disconnect cycles...)
    # You can *try* to update the firmware, or go as far as to connect with it on Windows with the
    # same bluetooth card.
    hardware.xpadneo.enable = true;

    environment.systemPackages = with pkgs; [
      protonup
      inputs.mint.packages.${system}.mint
    ];
  };
}
