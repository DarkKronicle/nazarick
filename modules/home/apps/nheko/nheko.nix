{
  lib,
  qt6,
  runCommand,
  makeWrapper,
  gst_all_1,
  pipewire,
}:
let
  nheko-unwrapped = (qt6.callPackage ./nheko-unwrapped.nix { });
  good_plugins = (gst_all_1.gst-plugins-good.override { qt6Support = true; });
  plugins = [
    "${gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0"
    "${good_plugins}/lib/gstreamer-1.0"
    "${gst_all_1.gst-plugins-base}/lib/gstreamer-1.0"
    "${gst_all_1.gstreamer.out}/lib/gstreamer-1.0"
    "${pipewire}/lib/gstreamer-1.0"
  ];
in
runCommand nheko-unwrapped.name
  {
    inherit (nheko-unwrapped) pname version meta;
    nativeBuildInputs = [ makeWrapper ];
  }
  ''
    mkdir -p $out/bin
    ln -s ${nheko-unwrapped}/share $out/share
    makeWrapper ${nheko-unwrapped}/bin/nheko $out/bin/nheko --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${lib.concatStringsSep ":" plugins}
  ''
