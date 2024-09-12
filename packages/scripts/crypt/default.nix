{ pkgs-unstable, ... }:
{
  name = "crypt";
  type = "nu";
  source = ./crypt.nu;
  dependencies = with pkgs-unstable; [
    age
    wormhole-rs
    picocrypt-cli
    diceware
    tomb
  ];
}
