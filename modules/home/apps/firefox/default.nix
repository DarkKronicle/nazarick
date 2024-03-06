{ lib, config, pkgs, inputs, ... }:

let
  inherit (lib) types mkEnableOption mkIf;
  inherit (lib.nazarick) mkOpt enabled;

  cfg = config.nazarick.apps.firefox;
in
{
  options.nazarick.apps.firefox = {
    enable = mkEnableOption "Firefox";
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;

      profiles = {
        main = {
          id = 0;
          name = "main";
          isDefault = true;
          userChrome = ''
            @import "${pkgs.nazarick.firefox-cascade}/chrome/userChrome.css";
          '';

          settings = {
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
          };
        };
      };
    };
  };
}
