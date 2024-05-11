{
  options,
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (lib.nazarick) mkBoolOpt;
  cfg = config.nazarick.system.printing;
in
{
  options.nazarick.system.printing = {
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
