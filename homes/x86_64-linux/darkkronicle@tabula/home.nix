{
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
