{ pkgs, lib, rustPlatform, inputs, fetchFromGitHub, ... }:

let 
  toolchain = with inputs.fenix.packages.x86_64-linux;
    combine [
      minimal.rustc
      minimal.cargo
      targets.x86_64-pc-windows-gnu.latest.rust-std
      targets.x86_64-pc-windows-gnu.latest.rust-std
    ];
in
(pkgs.makeRustPlatform {
  cargo = toolchain; 
  rustc = toolchain; 
}).buildRustPackage rec {
  pname = "mint";
  version = "master";
  src = fetchFromGitHub {
    owner = "trumank";
    repo = "mint";
    rev = "61755a9be8daf782d1af7366ea358d587b284935";
    hash = "sha256-yhlCoA3e5oTJ56aXeGYBt4PL0STM/GwZoHUAlc0Skd8=";
  };

  cargoSha256 = lib.fakeSha256;

  cargoLock = {
    lockFileContents = builtins.readFile ./Cargo.lock;

    outputHashes = {
      "egui_animation-0.1.0" = "sha256-d4TsVU0uvuNhmooVppd1r08xgJjSnVqTv2H0rLG8sCU=";
      "modio-0.7.1" = "sha256-/hlTSsKbSyDcQVTu5DSEHVcupOHrcmE3HHcMNKUgsCY=";
      "oodle_loader-0.2.1" = "sha256-tsEKGWUwH4V0hvSLV+CHgCbb7CpNg6k2ZucZq+Yekjk=";
      "patternsleuth-0.1.0" = "sha256-ahpWh4JcZG/g93YEJGABG2sfZf5V3halTl3NcrtKHcM=";
      "uasset_utils-0.1.0" = "sha256-dE5We2E8wwoUod5+XvBv4aYKeivfJDd8yj0rDo5Xmzs=";
      "unreal_asset-0.1.16" = "sha256-jebAiKrndpGjd44/fhPdIR548zMYxueQ+CrRodzRKv0=";
    };
  };

  CARGO_BUILD_TARGET="x86_64-unknown-linux-gnu";

  cargoBuildFlags = [ "--target=x86_64-unknown-linux-gnu" ];

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  meta = with lib; {
    description = "Deep Rock Galactic mod patcher";
    maintainers = [];
    license = licenses.mit;
    homepage = "https://github.com/trumank/mint";
  };

  buildInputs = with pkgs; [
    glib
    glibc
    atk
    gtk3
    zstd
  ];


  nativeBuildInputs = with pkgs.buildPackages; [
    pkg-config
    glib
    glibc
    atk
    gtk3
    zstd
  ];

  depsBuildBuild = [
    pkgs.pkgsCross.mingwW64.stdenv.cc
    pkgs.pkgsCross.mingwW64.windows.pthreads
    pkgs.pkgsCross.mingwW64.zstd
    # pkgs.pkgsCross.mingwW64.router
  ];

  CARGO_TARGET_X86_64_PC_WINDOWS_GNU_RUSTFLAGS =
    "-L native=${pkgs.pkgsCross.mingwW64.windows.pthreads}/lib";

  # CARGO_BUILD_TARGET = "x86_64-pc-windows-gnu";
}

