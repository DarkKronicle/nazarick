{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick; let
  cfg = config.nazarick.tools.cli;
in {
  options.nazarick.tools.cli = with types; {
    enable = mkBoolOpt false "Enable base cli tools. There's also homemanager config with nushell";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fd
      fzf
      ripgrep
      unzip
    ];
  };
}
