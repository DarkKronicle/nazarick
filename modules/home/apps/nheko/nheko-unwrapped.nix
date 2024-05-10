{
  lib,
  pkgs,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  asciidoc,
  pkg-config,
  boost179,
  cmark,
  coeurl,
  curl,
  libevent,
  libsecret,
  lmdb,
  lmdbxx,
  nlohmann_json,
  olm,
  qtbase,
  qtimageformats,
  qtmultimedia,
  qttools,
  re2,
  spdlog,
  wrapQtAppsHook,
  voipSupport ? true,
  gst_all_1,
  libnice,
  kdsingleapplication,
}:

let
  mtxclient = pkgs.callPackage ./mtx.nix { };
  good_plugins = (gst_all_1.gst-plugins-good.override { qt6Support = true; });
in
stdenv.mkDerivation {
  pname = "nheko";
  version = "0.11.4";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "nheko";
    rev = "7d9e3039fc2441fb622cad01b49f472d3289d70e";
    hash = "sha256-h4dxZydSbC9NMJIYWibmwnzlUntA9442dZ4MqbkyU7g=";
  };

  nativeBuildInputs = [
    asciidoc
    cmake
    lmdbxx
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs =
    [
      boost179
      cmark
      coeurl
      curl
      libevent
      libsecret
      lmdb
      mtxclient
      nlohmann_json
      olm
      qtbase
      qtimageformats
      qtmultimedia
      qttools
      re2
      kdsingleapplication
      pkgs.kdePackages.qtkeychain
      spdlog
    ]
    ++ lib.optionals voipSupport (
      with gst_all_1;
      [
        gstreamer
        gst-plugins-base
        good_plugins
        gst-plugins-bad
        libnice
      ]
    );

  cmakeFlags = [
    "-DCOMPILE_QML=ON" # see https://github.com/Nheko-Reborn/nheko/issues/389
    # "-DBUILD_SHARED_LIBS=OFF"
    # "-DUSE_BUNDLED_OPENSSL=OFF"
    # "-DUSE_BUNDLED_LMDB=OFF"
    # "-DUSE_BUNDLED_QTKEYCHAIN=OFF"
    # "-DUSE_BUNDLED_KDSINGLEAPPLICATION=ON"
  ];

  preFixup = lib.optionalString voipSupport ''
    # add gstreamer plugins path to the wrapper
    # qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${gst_all_1.gst-plugins-bad}/lib/gstreamer-1.0")
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${good_plugins}/lib/gstreamer-1.0")
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${gst_all_1.gst-plugins-base}/lib/gstreamer-1.0")
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "${gst_all_1.gstreamer.out}/lib/gstreamer-1.0")
  '';

  meta = with lib; {
    description = "Desktop client for the Matrix protocol";
    homepage = "https://github.com/Nheko-Reborn/nheko";
    license = licenses.gpl3Plus;
    mainProgram = "nheko";
    maintainers = with maintainers; [
      ekleog
      fpletz
    ];
    platforms = platforms.all;
    # Should be fixable if a higher clang version is used, see:
    # https://github.com/NixOS/nixpkgs/pull/85922#issuecomment-619287177
    broken = stdenv.hostPlatform.isDarwin;
  };
}
