{
  config,
  lib,
  mylib,
  pkgs,
  mypkgs,
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
    web = lib.mkEnableOption "Web applications";
    school = lib.mkEnableOption "School applications";
    design = lib.mkEnableOption "Design applications";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.document {
      nazarick.cli = {
        pager.enable = lib.mkOverride 500 true;
      };
    })
    (lib.mkIf cfg.messaging {
      nazarick.app = {
        nheko.enable = lib.mkOverride 500 true;
      };

      home.packages = [
        pkgs.signal-desktop
      ];
    })
    (lib.mkIf cfg.design {
      nazarick.app = {
        krita.enable = lib.mkOverride 500 true;
        gimp.enable = lib.mkOverride 500 true;
      };
    })
    {
      home.packages =
        (lib.optionals cfg.messaging [ pkgs.mumble ])
        ++ (lib.optionals cfg.document [
          pkgs.libreoffice-qt
          pkgs.hunspell # spell check for libreoffice
          pkgs.pdfarranger
          pkgs.rnote
        ])
        ++ (lib.optionals cfg.web [
          pkgs.brave
          pkgs.qbittorrent
          pkgs.tor-browser
          pkgs.goldendict-ng
        ])
        ++ (lib.optionals cfg.school [
          pkgs.matlab
          pkgs.waveforms
          mypkgs.ltspice
          pkgs.ollama-cuda
          pkgs.aichat
        ]);
    }
  ];
}
