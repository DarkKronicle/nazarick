{
  config,
  lib,
  mylib,
  pkgs,
  mypkgs,
  inputs,
  ...
}:
let
  cfg = config.nazarick.app.common;

  document = with pkgs; [
    typst
    libreoffice-qt
    hunspell
    pdfarranger
    rnote
    zotero
    poppler-utils
    calibre
    goldendict-ng
  ];

  useful = with pkgs; [
    (brave.override {
      commandLineArgs = "--password-store=basic";
    })
    qbittorrent
    tor-browser
    keepassxc
  ];

  tabula =
    with pkgs;
    [
      nheko
      signal-desktop
      mumble
      # waveforms
      matlab
      aichat
      prismlauncher

      # Fun apps
      pipes-rs
      thokr
      typespeed
      sssnake

      taskwarrior3
      khal
      supersonic-wayland
      jellyfin-tui

      rssguard

      inputs.timr.packages.${system}.timr
      inputs.faerber.packages.${system}.faerber
      pkgs.pinentry-gnome3
    ]
    ++ [
      mypkgs.ltspice
    ];
in
{

  imports = mylib.scanPaths ./.;

  options.nazarick.app.common = {
    document = lib.mkEnableOption "Document applications";
    useful = lib.mkEnableOption "Useful applications";
    tabula = lib.mkEnableOption "Tabula specific applications";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.document {
      nazarick.cli = {
        pager.enable = lib.mkOverride 500 true;
      };
    })
    (lib.mkIf cfg.document {
      nazarick.app = {
        krita.enable = lib.mkOverride 500 true;
        gimp.enable = lib.mkOverride 500 true;
      };
    })
    {
      home.packages =
        (lib.optionals cfg.document document)
        ++ (lib.optionals cfg.useful useful)
        ++ (lib.optionals cfg.tabula tabula);
    }
    (lib.mkIf cfg.tabula {
      services.vdirsyncer = {
        enable = true;
        frequency = "*:00/30:00";
      };
    })
  ];
}
