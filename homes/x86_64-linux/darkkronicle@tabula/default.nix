{
  lib,
  pkgs,
  config,
  ...
}:
with lib.nazarick;
{

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
      ov = {
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
      mpv = {
        enable = true;
      };
      defaults = {
        enable = true;
      };
      neovim = {
        enable = true;
      };
    };
  };
}
