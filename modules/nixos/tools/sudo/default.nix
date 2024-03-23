{ config, lib, ... }:
with lib;
with lib.nazarick;
let
  cfg = config.nazarick.tools.cli;
in
{
  # TODO: Move this to a suite
  options.nazarick.tools.sudo = with types; {
    enable = mkBoolOpt false "Enable sudo configuration";
    removeFirstMessage = mkBoolOpt true "Remove first message about sudo";
  };
  config = mkIf cfg.enable {
    security.sudo = {
      # Defaults  lecture_file="/path/to/file" - could be fun
      extraConfig = ''
        Defaults  lecture="never"
      '';
    };
  };
}
