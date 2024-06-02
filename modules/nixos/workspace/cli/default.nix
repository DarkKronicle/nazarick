{
  config,
  lib,
  mylib,
  pkgs,
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

    environment.systemPackages = with pkgs; [
      fd
      fzf
      ripgrep
      unzip
      gnupg
      acpi
      ouch
      gfshare
      age
    ];

    nazarick.workspace.cli.sudo.enable = lib.mkOverride 500 true;
  };
}
