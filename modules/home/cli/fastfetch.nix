{
  pkgs,
  options,
  config,
  lib,
  ...
}:
let

  cfg = config.nazarick.cli.fastfetch;

in
{
  options.nazarick.cli.fastfetch = {
    enable = lib.mkEnableOption "fastfetch";

  };

}
