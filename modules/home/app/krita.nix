{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.nazarick.app.krita;

  # KDE has a problem where they think things should just be stored
  # in top level config files. This is *really* annoying with impermanence.
  # So we just trick krita into thinking configs are in another directory, *hopefully* I don't need to symlink
  # all of config..
  kritaWrapped =
    let
      krita = pkgs.krita;
    in
    pkgs.symlinkJoin {
      inherit (krita) name version;
      paths = [ krita ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/krita \
          --set XDG_CONFIG_HOME "/home/${config.home.username}/.config/krita"
      '';
    };
in
{
  options.nazarick.app.krita = {
    enable = lib.mkEnableOption "krita";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      kritaWrapped
    ];
  };

}
