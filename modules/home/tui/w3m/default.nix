{
  config,
  pkgs,
  lib,
  ...
}:
let

  cfg = config.nazarick.tui.w3m;

  w3mWrapped =
    let
      w3m = pkgs.w3m;
    in
    pkgs.symlinkJoin {
      inherit (w3m) name version;
      paths = [ w3m ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/w3m \
          --set W3M_DIR "/home/${config.home.username}/.config/w3m"
      '';
    };

  configSub = pkgs.substitute {
    src = ./config;
    substitutions = [
      "--replace-fail"
      "@KITTEN@"
      "${pkgs.kitty}/bin/kitten"
    ];
  };
in
{

  options.nazarick.tui.w3m = {
    enable = lib.mkEnableOption "w3m";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      w3mWrapped
      pkgs.readability-cli
    ];

    xdg.configFile."w3m/config" = {
      enable = true;
      source = configSub;
    };

    xdg.configFile."w3m/keymap" = {
      enable = true;
      source = ./keymap;
    };

  };

}
