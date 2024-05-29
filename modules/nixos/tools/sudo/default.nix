{
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
  options.nazarick.tools.sudo = {
    enable = mkBoolOpt false "Enable sudo configuration";
    removeFirstMessage = mkBoolOpt true "Remove first message about sudo";
  };
  config = mkIf cfg.enable {
    security.sudo = {
      # Defaults  lecture_file="/path/to/file" - could be fun
      extraConfig = ''
        Defaults  lecture="never"
      '';
      extraRules = [
        {
          groups = [ "wheel" ];
          commands = [
            {
              command = "${pkgs.nazarick.tomb}/bin/tomb close";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
            {
              command = "${pkgs.nazarick.tomb}/bin/tomb slam";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
            {
              command = "${pkgs.nazarick.tomb}/bin/tomb list";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
          ];
        }
      ];
    };
  };
}
