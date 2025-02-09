{ pkgs, lib }:

let
  leaderModule = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/Seme4eg/mpv-scripts/bbf8785077c429f8172273ee16b2704a6a29da61/script-modules/leader.lua";
    hash = "sha256-eYBd7fXAUcSfWVXZHulXLHD+k4vsBG0NTvECGkKXSqY=";
  };
in
pkgs.mpvScripts.buildLua {
  pname = "mpv-leader";
  version = "2024-04-06";
  src = ./scripts/leader.lua;

  unpackPhase = ''
    cp $src leader.lua
  '';

  postPatch = ''
    substituteInPlace leader.lua --replace-fail 'leader-here-please' '${leaderModule}'
  '';

  meta = {
    description = "Adds leader key";
    license = lib.licenses.mit;
    homepage = "https://github.com/Seme4eg/mpv-scripts";
  };
}
