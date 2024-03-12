{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick; let
  cfg = config.nazarick.system.nvidia;
in {
  options.nazarick.system.nvidia = with types; {
    enable = mkBoolOpt false "Enable nvidia configuration.";
    nvidiaBusId = mkOpt str "" "Nvidia Bus ID";
    intelBusId = mkOpt str "" "Intel Bus ID";
  };
  config = mkIf cfg.enable {
    services.xserver.videoDrivers = ["nvidia"];

    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        vulkan-loader
        vulkan-validation-layers
        vulkan-extension-layer
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
  };
}
