{
  options,
  config,
  lib,
  mylib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (mylib) mkBoolOpt;
  cfg = config.nazarick.system.boot.plymouth;
in
{
  options.nazarick.system.boot.plymouth = {
    enable = mkBoolOpt false "Enable plymouth splash screen";
  };
  config = mkIf cfg.enable {

    boot = {
      initrd.systemd.enable = true;
      # consoleLogLevel = 0;
      # initrd.verbose = false;
      # kernelParams = [
      # "quiet"
      # "boot.shell_on_fail"
      # "loglevel=3"
      # "rd.systemd.show_status=false"
      # ];

      plymouth = {
        enable = true;
        theme = "lone";
        themePackages = [
          (pkgs.adi1090x-plymouth-themes.override {
            selected_themes = [ "lone" ]; # lone, pixels, deus ex, are good ones
          })
        ];
      };
    };
    # https://github.com/the-argus/nixsys/blob/99de33a277ecaee536d566c080e4f54eaef443d0/modules/plymouth.nix#L29C5-L31C1
    # systemd.services.plymouth-quit.serviceConfig.ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";

  };
}
