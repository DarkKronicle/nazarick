{ pkgs, lib, rustPlatform, fetchFromGitHub, ... }:

rustPlatform.buildRustPackage {
  pname = "mint";
  version = "master";
  src = fetchFromGitHub {
    owner = "trumank";
    repo = "mint";
    rev = "61755a9be8daf782d1af7366ea358d587b284935";
    hash = "sha256-yhlCoA3e5oTJ56aXeGYBt4PL0STM/GwZoHUAlc0Skd8=";
  };

  cargoHash = "";

  cargoLock = {
    lockFile = ./Cargo.lock;

    outputHashes = {
      "egui_animation-0.1.0" = "sha256-d4TsVU0uvuNhmooVppd1r08xgJjSnVqTv2H0rLG8sCU=";
      "modio-0.7.1" = "sha256-/hlTSsKbSyDcQVTu5DSEHVcupOHrcmE3HHcMNKUgsCY=";
      "oodle_loader-0.2.1" = "sha256-tsEKGWUwH4V0hvSLV+CHgCbb7CpNg6k2ZucZq+Yekjk=";
      "patternsleuth-0.1.0" = "sha256-ahpWh4JcZG/g93YEJGABG2sfZf5V3halTl3NcrtKHcM=";
      "uasset_utils-0.1.0" = "sha256-dE5We2E8wwoUod5+XvBv4aYKeivfJDd8yj0rDo5Xmzs=";
      "unreal_asset-0.1.16" = "sha256-jebAiKrndpGjd44/fhPdIR548zMYxueQ+CrRodzRKv0=";
    };
  };

  meta = with lib; {
    description = "Deep Rock Galactic mod patcher";
    maintainers = [];
  };
}

