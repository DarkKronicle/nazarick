{
  pkgs,
  fetchFromGitea,
  lib,
}:

let
in
pkgs.mpvScripts.buildLua {

  pname = "mpv-skipsilence";
  version = "2024-04-06";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "ferreum";
    repo = "mpv-skipsilence";
    rev = "2c9b50cc492ee517a41d5e8555c6e491f0b3998c";
    hash = "sha256-J06+gP/ND0wGQQPx1oTZuo6xhja2Ix2vK9xPtvhpJ8w=";
  };

  meta = {
    description = "Increase playback speed during silence";
    homepage = "https://codeberg.org/ferreum/mpv-skipsilence";
    license = lib.licenses.gpl2Only;
  };
}
