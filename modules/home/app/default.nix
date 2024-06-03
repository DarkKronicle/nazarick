{
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  cfg = config.nazarick.app.common;
in
{

  imports = mylib.scanPaths ./.;

  options.nazarick.app.common = {
    document = lib.mkEnableOption "Document editing applications";
    messaging = lib.mkEnableOption "Messaging applications";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.document {

      home.packages = with pkgs; [
        libreoffice-qt
        hunspell # spell check for libreoffice

        pdfarranger
        rnote
      ];

      nazarick.cli = {
        pager.enable = lib.mkOverride 500 true;
      };
    })
    (lib.mkIf cfg.messaging {

      nazarick.app = {
        vesktop.enable = lib.mkOverride 500 true;
        nheko.enable = lib.mkOverride 500 true;
      };
    })
  ];
}
