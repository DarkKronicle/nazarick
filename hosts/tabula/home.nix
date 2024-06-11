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
      common = {
        enable = true;
        fun = true;
        misc = true;
      };
      git = {
        enable = true;
        userEmail = "darkkronicle@gmail.com";
        userName = "DarkKronicle";
      };
      jujutsu = enabled;
      nushell = enabled;
      broot = enabled;
      pager = enabled;
      security = enabled;
      tex = enabled;
      rust = enabled;
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
      common = {
        document = true;
        messaging = true;
        web = true;
        school = true;
      };
      firefox = enabled;
      kitty = enabled;
      thunderbird = enabled;
      mpv = enabled;
      anki = {
        enable = true;
        other-pkgs = true;
      };
      spotify.spotify-qt = enabled;
      game = {
        minecraft = enabled;
      };
    };

    security.firejail = enabled;
  };
}
