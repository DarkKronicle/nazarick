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
  };

  nazarick = {
    core.nix = enabled;

    cli = {
      common = {
        enable = true;
      };
      nushell = enabled;
      pager = enabled;
    };

    tui = {
      btop = enabled;
      yazi = enabled;
    };

  };
}
