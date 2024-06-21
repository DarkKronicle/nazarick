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

    home.packages =
      import (mylib.relativeToRoot "modules/shared/cli.nix") { inherit pkgs mypkgs; }
      ++ (lib.optionals cfg.fun (with pkgs; [ pipes-rs ]))
      ++ (lib.optionals cfg.misc ([
        pkgs.yt-dlp
        (mypkgs.tomato-c.override {
          # Home manager simlinks mpv configs, so this forces a fresh config.
          # This is mainly an issue with sounds because it pulls up a window in my config
          mpv = pkgs.mpv-unwrapped.wrapper {
            mpv = pkgs.mpv-unwrapped;
            extraMakeWrapperArgs = [
              "--add-flags"
              "--config-dir=/home/${config.home.username}/.config/mpv2"
            ];
          };
        })
        inputs.faerber.packages.${system}.faerber
      ]));

    nazarick.cli = {
      pager.enable = lib.mkOverride 500 true;
      starship.enable = lib.mkOverride 500 true;
      eza.enable = lib.mkOverride 500 true;
    };

  };
}
