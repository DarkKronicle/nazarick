{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib.nazarick) enabled;
in
{
  imports = [ inputs.persist-retro.nixosModules.home-manager.persist-retro ];

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

  nazarick = {
    plasma = {
      enable = true;
      noBorders = true;
      panels = enabled;
    };

    tools = {
      git = {
        enable = true;
        userEmail = "darkkronicle@gmail.com";
        userName = "DarkKronicle";
      };
      jujutsu = enabled;
      nushell = enabled;
      pager = enabled;
      playerctl = enabled;
      easyeffects = enabled;
      kdeconnect = enabled;
      fcitx = enabled;
      security = enabled;
    };

    apps = {
      firefox = enabled;
      kitty = enabled;
      yazi = enabled;
      btop = enabled;
      thunderbird = enabled;
      mpv = enabled;
      defaults = enabled;
      neovim = enabled;
    };
    bundles = {
      messaging = enabled;
      document = enabled;
    };
  };
}
