# Run me as sudo!
# First argument is boot drive, second is btrfs encrypted partition

def main [boot_part: path, root_part: path, --mapper: string = "cryptroot"] {
  cryptsetup open $root_part cryptroot

  mkdir /mnt
  mount -o subvol=@,compress=zstd,noatime $"/dev/mapper/($mapper)" /mnt
  
  mkdir /mnt/nix
  mkdir /mnt/home
  mkdir /mnt/boot
  mount -o subvol=@nix,compress=zstd,noatime $"/dev/mapper/($mapper)" /mnt/nix
  mount -o subvol=@home,compress=zstd,noatime $"/dev/mapper/($mapper)" /mnt/home
  mount $boot_part /mnt/boot
}
