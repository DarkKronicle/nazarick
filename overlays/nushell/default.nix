{ pkgs-unstable, ... }:

final: prev:

{
  # My scripts and workflow requires the newest nushell
  nushell = pkgs-unstable.nushell;
}
