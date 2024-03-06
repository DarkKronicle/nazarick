{ pkgs, lib, ... }:

pkgs.fetchFromGitHub{
  name = "firefox-cascade";
  owner = "DarkKronicle";
  repo = "cascade";
  rev = "994edba071341b4afa9483512d320696ea10c0a6";
  sha256 = "sha256-DX77qLtDktv077YksxnrSoqa8O0ujJF2NH36GkENaXI=";
}
