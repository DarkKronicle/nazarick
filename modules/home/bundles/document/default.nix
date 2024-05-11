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
  cfg = config.nazarick.bundles.document;
in
{
  options.nazarick.bundles.document = {
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
