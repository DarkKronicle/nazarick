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
  compsize
  gtrash
  dust
  neovim
  nushell
  eza
  dysk
  magic-wormhole-rs
  mosh
  e2fsprogs
  sshfs
])
++ (with mypkgs; [ tomb ])
