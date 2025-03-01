{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nazarick.cli.eza;
in
{
  options.nazarick.cli.eza = {
    enable = lib.mkEnableOption "eza config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      eza
    ];
    nazarick.cli.nushell.alias = {
      # "xt" = "eza -T -L=3 --icons";
      "xi" = "eza --icons";
      "x" = "eza --icons -l -b -h --no-user --no-permissions --group-directories-first";
      "xl" = "eza --icons -l -b -h --group-directories-first --group";
      "xm" =
        "eza --icons -l -b -h --no-user --no-permissions --group-directories-first --sort modified --reverse";
    };
  };

}
