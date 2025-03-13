{
  options,
  config,
  mylib,
  lib,
  pkgs,
  ...
}:
let
  inherit (mylib) mkBoolOpt;

  cfg = config.nazarick.system.security;

  wordlists = pkgs.fetchFromGitHub {
    owner = "sts10";
    repo = "orchard-street-wordlists";
    rev = "bdfc36704da2d5b545a7ecb1daf15f8414ccaf93";
    hash = "sha256-C2Db8sCn9cbeswsMb5m2ybYqlHlBV92qqbscXA/YUX0=";
  };
in
{
  options.nazarick.system.security = {
    wordlists = mkBoolOpt true "Enable wordlists";
  };

  config = {
    system.activationScripts.makeWordlist = lib.mkIf cfg.wordlists (
      lib.stringAfter [ "var" ] ''
        mkdir -p /var/lib/wordlists
        chmod 755 /var/lib/wordlists

        ln -s -f ${wordlists}/lists/* /var/lib/wordlists/
      ''
    );
  };
}
