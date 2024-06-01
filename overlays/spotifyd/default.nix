{ pkgs-stable, ... }:

final: prev:

{
  # For some *unkown* reason, spotifyd has decided it wants to rebuild itself each 
  # update if on unstable. So that's why it's pinned to stable.
  inherit (pkgs-stable) spotifyd;
}
