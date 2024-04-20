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
  cfg = config.nazarick.bundles.document;
in
{
  options.nazarick.bundles.document = with types; {
    enable = mkBoolOpt false "Enable document editing packages";
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice-qt
      hunspell # spell check for libreoffice

      pdfarranger
      rnote
    ];
  };
}
