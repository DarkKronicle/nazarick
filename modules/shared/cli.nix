# cli tools that I want on every system, even if not NixOS, and accessible with home-manager failing
{ pkgs, mypkgs }:
(with pkgs; [
  wl-clipboard
  bandwhich
  libqalculate
  gnumake
  gcc
  wget
  git
  age
  fd
  fzf
  ripgrep
  unzip
  gnupg
  acpi
  ouch
  gfshare
  # TODO: add back
  # compsize
  gtrash
  dust
  neovim
  nushell
  dysk
  magic-wormhole-rs
  mosh
  e2fsprogs
  sshfs
  usbutils
  inxi
  file
  tomb
  qrencode
  imagemagick
  brightnessctl
  minisign
  resvg
  phraze
  yt-dlp
  ffmpeg-full
  sendme
  uni

  lsof
])
++ [
  mypkgs.tlock
  mypkgs.shamir
]
