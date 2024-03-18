{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick;
let
  cfg = config.nazarick.suites.document;
in
{
  options.nazarick.suites.document = with types; {
    enable = mkBoolOpt false "Enable document editing packages";
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      libreoffice-qt
      hunspell # spell check for libreoffice

      pdfarranger
    ];
  };
}
