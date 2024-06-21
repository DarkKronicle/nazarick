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
    core.nix = enabled;

    cli = {
      common = {
        enable = true;
        misc = true;
      };
      git = {
        enable = true;
        userEmail = "darkkronicle@gmail.com";
        userName = "DarkKronicle";
      };
      nushell = enabled;
      pager = enabled;
    };

    tui = {
      neovim = enabled;
      btop = enabled;
      yazi = enabled;
      broot = enabled;
    };

  };
}
