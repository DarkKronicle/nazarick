{ pkgs, ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";

  settings.on-unmatched = "debug";

  programs.nixfmt.enable = true;
  programs.prettier.enable = true;
}
