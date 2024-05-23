{
  options,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.nazarick) mkBoolOpt;

  cfg = config.nazarick.tools.cli;
in
{
  # TODO: Move this to a suite
  options.nazarick.tools.cli = {
    enable = mkBoolOpt false "Enable base cli tools. There's also homemanager config with nushell";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      fd
      fzf
      ripgrep
      unzip
      gnupg
      acpi
      ouch
      gfshare
      age
    ];
    services.pcscd.enable = true;
  };
}
