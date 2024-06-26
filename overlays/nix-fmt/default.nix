{ pkgs-unstable, ... }:

final: prev:

{
  # Building formats, so I want to make sure they're the same
  nixfmt-rfc-style = pkgs-unstable.nixfmt-rfc-style;
}
