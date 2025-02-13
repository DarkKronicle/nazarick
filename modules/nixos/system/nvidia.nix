{
  options,
  config,
  mylib,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf types;
  inherit (mylib) mkBoolOpt mkIfElse mkOpt;

  cfg = config.nazarick.system.nvidia;
in
{
  options.nazarick.system.nvidia = {
    enable = mkBoolOpt false "Enable nvidia configuration.";
    blacklist = mkBoolOpt false "Blacklist nvidia GPU";
    nvidiaBusId = mkOpt types.str "" "Nvidia Bus ID";
    intelBusId = mkOpt types.str "" "Intel Bus ID";
  };
  config =
    mkIfElse cfg.enable
      {
        services.xserver.videoDrivers = [ "nvidia" ];

        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            vulkan-loader
            vulkan-validation-layers
            vulkan-extension-layer
            vaapiVdpau
          ];
        };

        hardware.nvidia = {
          powerManagement.finegrained = false;
          powerManagement.enable = true;

          open = true;

          package = config.boot.kernelPackages.nvidiaPackages.latest;

          prime = {
            sync.enable = true;

            nvidiaBusId = cfg.nvidiaBusId;
            intelBusId = cfg.intelBusId;
          };
        };

        # https://github.com/ventureoo/nvidia-tweaks
        # https://github.com/TLATER/dotfiles/blob/5eb6f6ac73e2324e3d5ccac9b73fe1f2358ef451/nixos-config/hosts/yui/nvidia/default.nix#L32
        boot.extraModprobeConfig =
          "options nvidia " + lib.concatStringsSep " " [ "NVreg_UsePageAttributeTable=1" ];
      }
      (
        mkIf cfg.blacklist {
          boot.extraModprobeConfig = ''
            blacklist nouveau
            options nouveau modeset=0
          '';

          services.udev.extraRules = ''
            # Remove NVIDIA USB xHCI Host Controller devices, if present
            ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
            # Remove NVIDIA USB Type-C UCSI devices, if present
            ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
            # Remove NVIDIA Audio devices, if present
            ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
            # Remove NVIDIA VGA/3D controller devices
            ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
          '';
          boot.blacklistedKernelModules = [
            "nouveau"
            "nvidia"
            "nvidia_drm"
            "nvidia_modeset"
          ];
        }
      );
}
