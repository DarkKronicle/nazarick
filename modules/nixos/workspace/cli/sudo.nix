{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;
  cfg = config.nazarick.workspace.cli.sudo;
in
{
  options.nazarick.workspace.cli.sudo = {
    enable = mkBoolOpt false "Enable sudo configuration";
    removeFirstMessage = mkBoolOpt true "Remove first message about sudo";
  };
  config = mkIf cfg.enable {
    security.sudo = {
      # Defaults  lecture_file="/path/to/file" - could be fun
      extraConfig = ''
        Defaults  lecture="never"
        Defaults env_keep += "EDITOR PATH DISPLAY"
      '';
      extraRules = [
        {
          groups = [ "wheel" ];
          commands = [
            {
              command = "${pkgs.tomb}/bin/tomb close";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
            {
              command = "${pkgs.tomb}/bin/tomb slam";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
            {
              command = "${pkgs.tomb}/bin/tomb list";
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
