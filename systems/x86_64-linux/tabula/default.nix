{ pkgs, lib, nixos-hardware, ... }:

with lib;
with lib.internal;
{
  imports = [ ./hardware.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tabula"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  time.timeZone = "America/Denver";

  services.xserver.enable = true;
  services.printing.enable = true;

  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = true;
  
  fileSystems = {
    "/".options = [ "compress=zstd" "noatime" ];
    "/home".options = [ "compress=zstd" "noatime" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
    "/boot".options = [ "umask=0077" ];
  };

  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    gcc
    firefox
  ];

  # nazarick = {

  # };

  system.stateVersion = "23.11"; # Did you read the comment?

}
