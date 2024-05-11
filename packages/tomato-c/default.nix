# Updated from https://github.com/NixOS/nixpkgs/blob/58a1abdbae3217ca6b702f03d3b35125d88a2994/pkgs/applications/misc/tomato-c/default.nix#L76
# The flake from tomato-c didn't build on my machine
{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  libnotify,
  makeWrapper,
  mpv,
  ncurses,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tomato-c";
  version = "unstable-2024-04-19";

  src = fetchFromGitHub {
    owner = "gabrielzschmitz";
    repo = "Tomato.C";
    rev = "b3b85764362a7c120f3312f5b618102a4eac9f01";
    hash = "sha256-7i+vn1dAK+bAGpBlKTnSBUpyJyRiPc7AiUF/tz+RyTI=";
  };
  # patches = [
  # Adds missing function declarations required by newer versions of clang.
  # (fetchpatch {
  # url = "https://github.com/gabrielzschmitz/Tomato.C/commit/ad6d4c385ae39d655a716850653cd92431c1f31e.patch";
  # hash = "sha256-3ormv59Ce4rOmeyL30QET3CCUIOrRYMquub+eIQsMW8=";
  # })
  # ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "sudo " ""
    # Need to define _ISOC99_SOURCE to use `snprintf` on Darwin
    substituteInPlace notify.c \
      --replace-fail "/usr/local" "${placeholder "out"}"
    substituteInPlace util.c \
      --replace-fail "/usr/local" "${placeholder "out"}"
    substituteInPlace tomato.desktop \
      --replace-fail "/usr/local" "${placeholder "out"}"
  '';

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    libnotify
    mpv
    ncurses
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  installFlags = [
    "CPPFLAGS=$NIX_CFLAGS_COMPILE"
    "LDFLAGS=$NIX_LDFLAGS"
  ];

  postFixup = ''
    for file in $out/bin/*; do
      wrapProgram $file \
        --prefix PATH : ${
          lib.makeBinPath [
            libnotify
            mpv
          ]
        }
    done
  '';

  strictDeps = true;

  meta = {
    homepage = "https://github.com/gabrielzschmitz/Tomato.C";
    description = " A pomodoro timer written in pure C";
    license = lib.licenses.gpl3Plus;
    mainProgram = "tomato";
    platforms = lib.platforms.unix;
  };
})
