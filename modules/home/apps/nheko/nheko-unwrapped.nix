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
  pipewire,
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
    rev = "1c5f747856031c8e8df161f2d425bb6cece01bcd";
    hash = "sha256-Mv0MjH9Y6q7ihmkt+Grl1+NL5ExlYqaCUeT0VczVjxI=";
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
        pipewire
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
    qtWrapperArgs+=(--prefix GST_PLUGIN_SYSTEM_PATH_1_0 : "$GST_PLUGIN_SYSTEM_PATH_1_0")
  '';

  meta = {
    description = "Desktop client for the Matrix protocol";
    homepage = "https://github.com/Nheko-Reborn/nheko";
    license = lib.licenses.gpl3Plus;
    mainProgram = "nheko";
    maintainers = with lib.maintainers; [
      ekleog
      fpletz
    ];
    platforms = lib.platforms.all;
    # Should be fixable if a higher clang version is used, see:
    # https://github.com/NixOS/nixpkgs/pull/85922#issuecomment-619287177
    broken = stdenv.hostPlatform.isDarwin;
  };
}
