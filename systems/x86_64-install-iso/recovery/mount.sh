# Run me as sudo!
# First argument is boot drive, second is btrfs encrypted partition

cryptsetup open $2 cryptroot

mkdir /mnt
mount -o subvol=@,compress=zstd,noatime /dev/mapper/cryptroot /mnt

mkdir /mnt/nix
mkdir /mnt/home
mkdir /mnt/boot
mount -o subvol=@nix,compress=zstd,noatime /dev/mapper/cryptroot /mnt/nix
mount -o subvol=@home,compress=zstd,noatime /dev/mapper/cryptroot /mnt/home
mount $1 /mnt/boot
