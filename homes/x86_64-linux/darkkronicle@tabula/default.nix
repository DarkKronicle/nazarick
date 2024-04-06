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

  xdg.desktopEntries."anki" = {
    name = "Anki";
    comment = "An intelligent spaced-repetition memory training program";
    genericName = "Flashcards";
    type = "Application";
    mimeType = [
      "application/x-apkg"
      "application/x-anki"
      "application/x-ankiaddon"
    ];
    icon = "anki";
    # TODO: don't rely on $PATH. This currently errors with `nazarick` not found. Probably snowfall thing.
    # exec = "env QT_SCALE_FACTOR_ROUNDING_POLICY=RoundPreferFloor ${pkgs.nazarick.anki}/bin/anki";
    exec = "env QT_SCALE_FACTOR_ROUNDING_POLICY=RoundPreferFloor anki";
    settings = {
      SingleMainWindow = "true";
    };
    categories = [
      "Education"
      "Languages"
    ];
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
