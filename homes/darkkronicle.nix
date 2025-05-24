{
  lib,
  pkgs,
  mylib,
  config,
  inputs,
  mysecrets,
  osConfig,
  myvars,
  ...
}:
let
  enabled = {
    enable = lib.mkDefault true;
  };

  systemType = myvars.system.type; # laptop, desktop, server
  isType = list: builtins.elem systemType list;
  personalComputer = [
    "laptop"
    "desktop"
  ];
  isPersonalComputer = isType personalComputer;
  enablePersonalComputer = {
    enable = lib.mkDefault isPersonalComputer;
  };
in
{

  nazarick = {
    core.xdg = enablePersonalComputer;
    core.nix = enabled;

    gui = lib.mkIf isPersonalComputer {
      qt = enabled;
      ags = enabled;
      sway = enabled;
      fcitx = enabled;
    };

    cli = {
      common = {
        enable = lib.mkDefault true;
        fun = isPersonalComputer;
        misc = isPersonalComputer;
      };
      fastfetch = enablePersonalComputer;
      git = {
        enable = lib.mkDefault true;
        userEmail = "darkkronicle@gmail.com";
        userName = "DarkKronicle";
      };
      jujutsu = enabled;
      nushell = {
        enable = lib.mkDefault true;
        useKittyProtocol = lib.mkDefault isPersonalComputer;
      };
      pager = enabled;
      rust = enablePersonalComputer;
    };

    service = {
      spotifyd = enablePersonalComputer;
      playerctl = enablePersonalComputer;
      syncthing = enablePersonalComputer;
      easyeffects = enablePersonalComputer;
      kdeconnect = enablePersonalComputer;
    };

    tui = {
      neovim = enabled;
      btop = enabled;
      yazi = enabled;
      broot = enabled;
      zellij = enabled;
    };

    app = lib.mkIf isPersonalComputer {
      common = {
        document = lib.mkDefault true;
        useful = lib.mkDefault true;
        tabula = osConfig.networking.hostName == "tabula";
      };
      firefox = enabled;
      kitty = enabled;
      thunderbird = enabled;
      ollama = enabled;
      obs = enabled;
      mpv = enabled;
      anki = {
        enable = lib.mkDefault true;
        other-pkgs = lib.mkDefault true;
      };
      # spotify.spotify-qt = enabled;
      game = {
        protonup = enabled;
      };
    };

    security.firejail = enablePersonalComputer;
  };
}
