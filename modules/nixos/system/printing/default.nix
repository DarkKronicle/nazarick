{
  options,
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with lib.nazarick; let
  cfg = config.nazarick.system.printing;
in 
{
  options.nazarick.system.printing = with types; {
    enable = mkBoolOpt false "Enable printing support.";
  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        hplip
        # hplipWithPlugin # - proprietary
      ];
    };
    # Auto-discover printers
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };

}
