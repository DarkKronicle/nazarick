{
  config,
  pkgs,
  lib,
  ...
}:
let

  pluginDerivation =
    attrs:
    let
      name = attrs.name or "${attrs.pname}-${attrs.version}";
    in
    pkgs.stdenv.mkDerivation (
      {
        prePhases = "extraLib";
        extraLib = ''
          installScripts(){
            mkdir -p $out/${pkgs.gimp.targetScriptDir}/${name};
            for p in "$@"; do cp "$p" -r $out/${pkgs.gimp.targetScriptDir}/${name}; done
          }
          installPlugin() {
            # The base name of the first argument is the plug-in name and the main executable.
            # GIMP only allows a single plug-in per directory:
            # https://gitlab.gnome.org/GNOME/gimp/-/commit/efae55a73e98389e38fa0e59ebebcda0abe3ee96
            pluginDir=$out/${pkgs.gimp.targetPluginDir}/$(basename "$1")
            install -Dt "$pluginDir" "$@"
          }
        '';
      }
      // attrs
      // {
        name = "${pkgs.gimp.pname}-plugin-${name}";
        buildInputs = [
          pkgs.gimp
          pkgs.gimp.gtk
          pkgs.glib
        ]
        ++ (attrs.buildInputs or [ ]);

        nativeBuildInputs = [
          pkgs.pkg-config
          pkgs.intltool
        ]
        ++ (attrs.nativeBuildInputs or [ ]);

        # Override installation paths.
        env = {
          PKG_CONFIG_GIMP_2_0_GIMPLIBDIR = "${placeholder "out"}/${pkgs.gimp.targetLibDir}";
          PKG_CONFIG_GIMP_2_0_GIMPDATADIR = "${placeholder "out"}/${pkgs.gimp.targetDataDir}";
        }
        // attrs.env or { };
      }
    );

  cfg = config.nazarick.app.gimp;
  gimp-plugins = pkgs.gimp-with-plugins.override {
    plugins = [
      pkgs.gimpPlugins.gmic # Tons of filters, features, more photoshop-like stuff
    ];
  };

in
{
  options.nazarick.app.gimp = {
    enable = lib.mkEnableOption "gimp";
  };

  config = lib.mkIf cfg.enable { home.packages = [ gimp-plugins ]; };

}
