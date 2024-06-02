{
  config,
  lib,
  mylib,
  mypkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;
  cfg = config.nazarick.workspace.cli.sudo;
in
{
  # TODO: Move this to a suite
  options.nazarick.workspace.cli.sudo = {
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
              command = "${mypkgs.tomb}/bin/tomb close";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
            {
              command = "${mypkgs.tomb}/bin/tomb slam";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
            {
              command = "${mypkgs.tomb}/bin/tomb list";
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
