{ pkgs, extra-pkgs, ... }:
{
  name = "crypt";
  type = "nu";
  source = ./crypt.nu;
  dependencies =
    (with pkgs; [
      age
      wormhole-rs
      picocrypt-cli
      diceware
      tomb
    ])
    ++ (with extra-pkgs; [ tlock ]);
}
