{
  config,
  lib,
  mylib,
  pkgs,
  mypkgs,
  inputs,
  system,
  ...
}:
let
  cfg = config.nazarick.cli.common;
in
{

  imports = mylib.scanPaths ./.;

  options.nazarick.cli.common = {
    enable = lib.mkEnableOption "Common CLI configuration";
    fun = lib.mkEnableOption "Fun CLI configuration";
    misc = lib.mkEnableOption " Misc configuration";
  };

  config = lib.mkIf cfg.enable {

    nazarick.cli.nushell.alias = {
      "wrm" = "wormhole-rs";
      "xt" = "broot -c :pt --height ((term size).rows - 1) -H";
    };

    home.packages =
      import (mylib.relativeToRoot "modules/shared/cli.nix") { inherit pkgs mypkgs; }
      ++ (lib.optionals cfg.fun (
        with pkgs;
        [
          pipes-rs
          thokr
          typespeed
          sssnake
        ]
      ))
      ++ (lib.optionals cfg.misc ([
        pkgs.yt-dlp
        pkgs.taskwarrior3
        inputs.timr.packages.${system}.timr
        inputs.faerber.packages.${system}.faerber
        pkgs.pinentry-gnome3
      ]));

    nazarick.cli = {
      pager.enable = lib.mkOverride 500 true;
      starship.enable = lib.mkOverride 500 true;
    };

  };
}
