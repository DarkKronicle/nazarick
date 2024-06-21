{ pkgs-unstable, ... }:

final: prev:

{
  # My scripts and workflow requires the newest nushell
  neovim = pkgs-unstable.neovim;
}
