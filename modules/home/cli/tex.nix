{
  lib,
  config,
  mylib,
  pkgs,
  ...
}:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (mylib) mkOpt enabled;

  cfg = config.nazarick.cli.tex;
in
{
  options.nazarick.cli.tex = {
    enable = mkEnableOption "LaTeX";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (texlive.combine {
        inherit (texlive)
          scheme-medium
          circuitikz
          standalone
          svn-prov
          ;
      })
    ];
  };
}
