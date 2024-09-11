{
  lib,
  pkgs,
  mylib,
  config,
  inputs,
  mysecrets,
  myvars,
  ...
}:
let
  enabled = { enable = lib.mkDefault true; };

  systemType = myvars.system.type; # laptop, desktop, server
  isType = list: builtins.elem systemType list;
  personalComputer = [ "laptop" "desktop" ];
  isPersonalComputer = isType personalComputer;
  enablePersonalComputer = { enable = lib.mkDefault isPersonalComputer; };
in
{
  programs.ssh = {
    enable = true;
    # matchBlocks = {
      # "gitlab.com" = {
      # host = "gitlab.com";
      # hostname = "gitlab.com";
      # identityFile = [ "/home/darkkronicle/.ssh/id_nazarick" ];
      # extraOptions = {
      # PreferredAuthentications = "publickey";
      # };
      # };
    # };
  };

  nazarick = {
    core.xdg = enablePersonalComputer;
    core.nix = enabled;

    gui = lib.mkIf (isPersonalComputer) {
      plasma = {
        enable = lib.mkDefault true;
        noBorders = lib.mkDefault true;
        panels = enabled;
      };
      fcitx = enabled;
      mars = enabled;
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
      tex = enablePersonalComputer;
      rust = enablePersonalComputer;
    };

    service = {
      spotifyd = enablePersonalComputer;
      playerctl = enablePersonalComputer;
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
        messaging = lib.mkDefault true;
        web = lib.mkDefault true;
        school = lib.mkDefault true;
        design = lib.mkDefault true;
      };
      firefox = enabled;
      kitty = enabled;
      # thunderbird = enabled; # TODO: Maybre reanble?
      mpv = enabled;
      anki = {
        enable = lib.mkDefault true;
        other-pkgs = lib.mkDefault true;
      };
      spotify.spotify-qt = enabled;
      game = {
        protonup = enabled;
        mint = enabled;
        minecraft = enabled;
      };
    };

    security.firejail = enablePersonalComputer;
  };
}
