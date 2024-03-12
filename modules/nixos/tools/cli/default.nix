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
  # TODO: Move this to a suite
  options.nazarick.tools.cli = with types; {
    enable = mkBoolOpt false "Enable base cli tools. There's also homemanager config with nushell";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fd
      fzf
      ripgrep
      unzip
      gnupg
    ];
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = "curses";
    };
    services.pcscd.enable = true;
  };
}
