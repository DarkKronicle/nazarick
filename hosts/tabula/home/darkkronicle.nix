{
  lib,
  pkgs,
  mylib,
  config,
  inputs,
  mysecrets,
  ...
}:
let
  inherit (mylib) enabled;
in
{
  sops = {
    age.keyFile = "/home/darkkronicle/.config/sops/age/keys.txt";
    defaultSopsFile = "${mysecrets.src}/secrets.yaml";
  };

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
      pager = enabled;
      security = enabled;
      tex = enabled;
      rust = enabled;
    };

    service = {
      spotifyd = enabled;
      playerctl = enabled;
      easyeffects = enabled;
      kdeconnect = enabled;
    };

    tui = {
      neovim = enabled;
      btop = enabled;
      yazi = enabled;
      broot = enabled;
      newsboat = enabled;
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
        protonup = enabled;
        mint = enabled;
        minecraft = enabled;
      };
    };

    security.firejail = enabled;
  };
}
