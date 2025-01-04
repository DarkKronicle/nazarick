{ pkgs-unstable, ... }:
final: prev: {
  nu_scripts = pkgs-unstable.nu_scripts.overrideAttrs (_: {
    version = "0-unstable-2025-01-04";
    src = pkgs-unstable.fetchFromGitHub {
      owner = "nushell";
      repo = "nu_scripts";
      rev = "2dadab779b456667456eeb274bdf5c6a51f6d602";
      hash = "sha256-42TCEJCKaqnBML7r7b9AUUCgh48FKAjbmeixYdFbQ3M=";
    };
  });
}
