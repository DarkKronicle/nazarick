{ pkgs-unstable, ... }:

final: prev:

{
  # My scripts and workflow requires the newest nushell
  nushell = pkgs-unstable.nushell;
  nu_scripts = pkgs-unstable.nu_scripts;
}
