{
  pkgs,
  lib,
  nixos-hardware,
  config,
  inputs,
  ...
}:

# ./hardware.nix is for the pure-generated nix-generate-config. Here goes things that 
# are specific to this system, and don't quite fit into other modules.
with lib;
with lib.internal;
{
  fileSystems = {
    "/".options = [
      "compress=zstd"
      "noatime"
    ];
    "/home" = {
      options = [
        "compress=zstd"
        "noatime"
      ];
      neededForBoot = true; # Get keys from here
    };
    "/nix".options = [
      "compress=zstd"
      "noatime"
    ];
    "/boot".options = [ "umask=0077" ];
    "/swap".options = [ "noatime" ];
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];

  boot.kernelParams = [
    "nowatchdog"
    "nvme.noacpi=1"
  ];

  time.timeZone = "America/Denver";
}
