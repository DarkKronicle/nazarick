{
  lib,
  pkgs,
  mylib,
  config,
  inputs,
  mysecrets,
  ...
}:
let
  inherit (mylib) enabled;
in
{
  sops = {
    age.keyFile = "/home/darkkronicle/.config/sops/age/keys.txt";
    defaultSopsFile = "${mysecrets.src}/secrets.yaml";
  };

  # TODO: Move this
  programs.tofi = {
    enable = true;
    settings = {
      background-color = "#000000AA";
      border-width = 0;
      font = "monospace";
      height = "100%";
      num-results = 5;
      outline-width = 0;
      padding-left = "35%";
      padding-top = "35%";
      result-spacing = 25;
      width = "100%";
    };
  };

  nazarick = {
    service = {
      kanata.enable = true;
      logrotate.enable = true;
    };

    security.firejail = enabled;
  };

}
