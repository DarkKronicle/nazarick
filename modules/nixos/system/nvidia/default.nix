{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick;
let
  cfg = config.nazarick.system.nvidia;
in
{
  options.nazarick.system.nvidia = with types; {
    enable = mkBoolOpt false "Enable nvidia configuration.";
    blacklist = mkBoolOpt false "Blacklist nvidia GPU";
    nvidiaBusId = mkOpt str "" "Nvidia Bus ID";
    intelBusId = mkOpt str "" "Intel Bus ID";
  };
  config =
    mkIfElse cfg.enable
      {
        services.xserver.videoDrivers = [ "nvidia" ];

        hardware.opengl = {
          enable = true;
          driSupport = true;
          driSupport32Bit = true;
          extraPackages = with pkgs; [
            vulkan-loader
            vulkan-validation-layers
            vulkan-extension-layer
            vaapiVdpau
          ];
        };

        hardware.nvidia = {
          modesetting.enable = true;

          powerManagement.finegrained = false;
          powerManagement.enable = false;

          open = false;
          nvidiaSettings = true;

          package = config.boot.kernelPackages.nvidiaPackages.stable;

          prime = {
            sync.enable = true;

            nvidiaBusId = cfg.nvidiaBusId;
            intelBusId = cfg.intelBusId;
          };
        };
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
