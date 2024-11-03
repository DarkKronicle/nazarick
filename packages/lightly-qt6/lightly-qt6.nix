# https://github.com/boehs/Lightly/issues/13#issuecomment-2008120172
{
  fetchFromGitHub,
  mkKdeDerivation,
  extra-cmake-modules,
  kdecoration,
  plasma-workspace,
  fetchurl,
  lib,
}:

mkKdeDerivation {
  meta = {
    license = lib.licenses.gpl3;
    description = "A fork of Breeze";
  };

  pname = "lightly-qt6";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "Bali10050";
    repo = "Lightly";
    rev = "c281ad6705e9eec471ebcd5099131ea50d27c1ec";
    hash = "sha256-cBICf6DGg6s7vbqJZ/zo09Wjkvm/ztQCDB8XLoXL7S8=";
  };
  # Prevent conflict between qt6 and qt5
  postInstall = ''
    mv $out/share/kstyle/themes/lightly.themerc $out/share/kstyle/themes/lightly6.themerc
    mv $out/share/color-schemes/Lightly.colors $out/share/color-schemes/Lightly6.colors
  '';

  extraBuildInputs = [
    kdecoration
    plasma-workspace
    extra-cmake-modules
  ];
}
