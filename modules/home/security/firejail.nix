{
  lib,
  config,
  pkgs,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.nazarick.security.firejail;
in
{
  options.nazarick.security.firejail = {
    enable = mkEnableOption "firejail";
  };

  config = mkIf cfg.enable {
    # Make sure system level firejail is enabled
    programs.firejail = {
      enable = true;
      wrappedBinaries = {
        firefox = {
          executable = "${config.programs.firefox.finalPackage}/bin/firefox";
          profile = "${pkgs.firejail}/etc/firejail/firefox.profile";
        };
      };
    };
  };
}
