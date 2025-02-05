{ pkgs, extra-pkgs, ... }:
{
  name = "crypt";
  type = "nu";
  source = ./crypt.nu;
  dependencies =
    (with pkgs; [
      age
      wormhole-rs
      diceware
      tomb
      openssl
      curl
    ])
    ++ (with extra-pkgs; [ tlock ]);
}
