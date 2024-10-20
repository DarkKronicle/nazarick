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
    rev = "459466f7a845d0f98a82796418d8ebb03b7e5cbd";
    hash = "sha256-n4w6uMnBWNPwVE3vjTHGbzU9M6XgRafddkdxA7SafgQ=";
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
