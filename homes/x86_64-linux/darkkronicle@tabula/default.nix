{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib.nazarick;
{
  imports = [ inputs.persist-retro.nixosModules.home-manager.persist-retro ];

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "gitlab.com" = {
        host = "gitlab.com";
        hostname = "gitlab.com";
        identityFile = [ "/home/darkkronicle/.ssh/id_tabula" ];
        extraOptions = {
          PreferredAuthentications = "publickey";
        };
      };
    };
  };

  nazarick = {
    plasma = {
      enable = true;
      noBorders = true;
      panels = {
        enable = true;
      };
    };

    tools = {
      git = {
        enable = true;
        userEmail = "darkkronicle@gmail.com";
        userName = "DarkKronicle";
      };
      jujutsu = {
        enable = true;
      };
      nushell = {
        enable = true;
      };
      pager = {
        enable = true;
      };
      playerctl = {
        enable = true;
      };
      easyeffects = {
        enable = true;
      };
      kdeconnect = {
        enable = true;
      };
      fcitx = {
        enable = true;
      };
    };

    apps = {
      firefox = {
        enable = true;
      };
      kitty = {
        enable = true;
      };
      yazi = {
        enable = true;
      };
      thunderbird = {
        enable = true;
      };
      mpv = {
        enable = true;
      };
      defaults = {
        enable = true;
      };
      neovim = {
        enable = true;
      };
      anki = {
        enable = true;
      };
    };
  };
}
