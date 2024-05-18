{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  coeurl,
  curl,
  libevent,
  nlohmann_json,
  olm,
  openssl,
  re2,
  spdlog,
}:

stdenv.mkDerivation {
  pname = "mtxclient";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "Nheko-Reborn";
    repo = "mtxclient";
    rev = "58af2030c22e2dae7d6156c70572714c6363acee";
    hash = "sha256-BdlXfx8f7+fTXYVh6SxTJVDmqcjbM5p3MhNVRtFT2zU=";
  };

  postPatch = ''
    # See https://github.com/gabime/spdlog/issues/1897
    sed -i '1a add_compile_definitions(SPDLOG_FMT_EXTERNAL)' CMakeLists.txt
  '';

  cmakeFlags = [
    # Network requiring tests can't be disabled individually:
    # https://github.com/Nheko-Reborn/mtxclient/issues/22
    "-DBUILD_LIB_TESTS=OFF"
    "-DBUILD_LIB_EXAMPLES=OFF"
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    coeurl
    curl
    libevent
    nlohmann_json
    olm
    openssl
    re2
    spdlog
  ];

  meta = {
    description = "Client API library for the Matrix protocol.";
    homepage = "https://github.com/Nheko-Reborn/mtxclient";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      fpletz
      pstn
    ];
    platforms = lib.platforms.all;
    # Should be fixable if a higher clang version is used, see:
    # https://github.com/NixOS/nixpkgs/pull/85922#issuecomment-619287177
    broken = stdenv.hostPlatform.isDarwin;
  };
}