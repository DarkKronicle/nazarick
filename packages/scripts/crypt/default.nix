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
      openssl
      curl
    ])
    ++ (with extra-pkgs; [ tlock ]);
}
