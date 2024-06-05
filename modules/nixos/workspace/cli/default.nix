{
  config,
  lib,
  mylib,
  pkgs,
  mypkgs,
  ...
}:
let
  cfg = config.nazarick.workspace.cli.common;
in
{

  imports = mylib.scanPaths ./.;

  options.nazarick.workspace.cli.common = {
    enable = lib.mkEnableOption "Common CLI configuration";
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = import (mylib.relativeToRoot "modules/shared/cli.nix") {
      inherit pkgs mypkgs;
    };

    environment.shells = with pkgs; [ nushell ];

    nazarick.workspace.cli.sudo.enable = lib.mkOverride 500 true;
  };
}
