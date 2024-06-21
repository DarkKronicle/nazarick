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

    environment.systemPackages = with pkgs; [
      protonup
      inputs.mint.packages.${system}.mint
    ];
  };
}
