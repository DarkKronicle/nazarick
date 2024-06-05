{
  lib,
  pkgs,
  mylib,
  config,
  inputs,
  ...
}:
let
  inherit (mylib) enabled;
in
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "gitlab.com" = {
        host = "gitlab.com";
        hostname = "gitlab.com";
        identityFile = [ "/home/darkkronicle/.ssh/id_nazarick" ];
        extraOptions = {
          PreferredAuthentications = "publickey";
        };
      };
    };
  };

  home.packages = with pkgs; [ (rofimoji.override { x11Support = false; }) ];

  programs.tofi = {
    enable = true;
    settings = {
      background-color = "#000000AA";
      border-width = 0;
      font = "monospace";
      height = "100%";
      num-results = 5;
      outline-width = 0;
      padding-left = "35%";
      padding-top = "35%";
      result-spacing = 25;
      width = "100%";
    };
  };

  nazarick = {
    core.xdg = enabled;
    core.nix = enabled;

    gui = {
      plasma = {
        enable = true;
        noBorders = true;
        panels = enabled;
      };
      fcitx = enabled;
    };

    cli = {
      git = {
        enable = true;
        userEmail = "darkkronicle@gmail.com";
        userName = "DarkKronicle";
      };
      jujutsu = enabled;
      nushell = enabled;
      pager = enabled;
      security = enabled;
    };

    service = {
      playerctl = enabled;
      easyeffects = enabled;
      kdeconnect = enabled;
    };

    tui = {
      neovim = enabled;
      btop = enabled;
      yazi = enabled;
    };

    app = {
      common.document = true;
      common.messaging = true;
      firefox = enabled;
      kitty = enabled;
      thunderbird = enabled;
      mpv = enabled;
      anki = enabled;
      spotify.spotify-qt = enabled;
    };
  };
}
