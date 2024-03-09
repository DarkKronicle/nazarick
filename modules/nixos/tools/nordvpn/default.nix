{
  options,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
with lib.nazarick; let
  cfg = config.nazarick.tools.nordvpn;
  nur-no-pkgs = import inputs.nur {
    nurpkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
  };
in {
  options.nazarick.tools.nordvpn = with types; {
    enable = mkBoolOpt false "Enable nordvpn.";
  };
  imports = [
    nur-no-pkgs.repos.LuisChDev.modules.nordvpn
  ];
  config = mkIf cfg.enable {
    # environment.systemPackages = with pkgs; [
      # nur.repos.LuisChDev.nordvpn
    # ];

    services.nordvpn.enable = true;
  };
}
