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
      # extraRules = [{
      #  commands = [
      #   {
      #    command = "${pkgs.tomb}/bin/tomb";
      # }
      # ];
      #}];
    };
  };
}
