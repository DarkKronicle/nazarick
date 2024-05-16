{
  lib,
  config,
  options,
  pkgs,
  ...
}:
let
  inherit (lib.nazarick) enabled;
  
in
{
  # https://discourse.nixos.org/t/how-do-i-add-boot-menu-entries-to-an-install-iso/39748/3
  # This allows us to modify config.isoImage.contents after the rest of the
  # config has set it to something. See
  # <https://github.com/NixOS/nixpkgs/issues/16884#issuecomment-238814281>
  options.isoImage.contents = lib.options.mkOption {
    apply =
      list:
      lib.lists.forEach list (
        item:
        if item.target == "/EFI" then
          item
          // {
            source =
              let
                # I chose this name because the original package that I’m modifying
                # is called efi-directory:
                # <https://github.com/NixOS/nixpkgs/blob/ee76c70ea139274f1afd5f7d287c0489b4750fee/nixos/modules/installer/cd-dvd/iso-image.nix#L238>
                pkgName = "efi-directory-customized";
                customizedEfiDir =
                  pkgs.runCommand pkgName
                    {
                      nativeBuildInputs = [
                        pkgs.buildPackages.grub2_efi
                        pkgs.nushell
                      ];
                    }
                    ''
                      set -e
                      mkdir "$out"
                      cp -r ${item.source} "$out/EFI"
                      readonly grub_cfg="$out/EFI/boot/grub.cfg"

                      nu ${./grub_patch.nu} "$grub_cfg" "${config.system.build.toplevel}" "/boot/${config.system.boot.loader.kernelFile}"

                      grub-script-check "$grub_cfg"
                    '';
              in
              "${customizedEfiDir}/EFI";
          }
        else
          item
      );
  };

  specialisation = {
    generic.configuration = {
      environment.systemPackages = with pkgs; [
        (mumble.override { pulseSupport = true; })
      ];
      nazarick.tools.nordvpn = enabled;
    };
  };
}
